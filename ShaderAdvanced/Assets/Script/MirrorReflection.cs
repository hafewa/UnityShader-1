using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MirrorReflection : MonoBehaviour 
{

	Camera ReflectionCamera;
	RenderTexture rt;

	void Start () 
	{
		GameObject go = new GameObject ("ReflectionCamera");

		ReflectionCamera = go.AddComponent<Camera> ();

		//要和当前Game视图分辨率一致,创建投影纹理
		rt = new RenderTexture (1600, 600, 16);

		ReflectionCamera.targetTexture = rt;

		//这里一开始的时候还是要将摄像机关闭,因为下面要进行底层openGL的渲染库的反转,在摄像机ReflectionCamera.Render ()前进行反转,后再反转回来,如果不反转回来就会出现不对的画面
		ReflectionCamera.enabled = false;

		GetComponent<Renderer> ().material.SetTexture ("_MirrorTex", rt);
	}
	

	//在每一帧在即将渲染物体之前都会调用的函数,Update是正在渲染物体时调用
	//因为我们的矩阵变换要在物体渲染之前完成,所以选择这个方法而不是Update
	void OnWillRenderObject () 
	{
		//完全拷贝主相机的属性,用来渲染一张Rendtexture(镜面投影的纹理)
		Camera cam = Camera.current;
		ReflectionCamera.transform.position = cam.transform.position;
		ReflectionCamera.transform.rotation = cam.transform.rotation;
		ReflectionCamera.clearFlags = cam.clearFlags;
		ReflectionCamera.backgroundColor = cam.backgroundColor;
		ReflectionCamera.farClipPlane = cam.farClipPlane;
		ReflectionCamera.nearClipPlane = cam.nearClipPlane;
		ReflectionCamera.orthographic = cam.orthographic;
		ReflectionCamera.orthographicSize = cam.orthographicSize;
		ReflectionCamera.fieldOfView = cam.fieldOfView;
		ReflectionCamera.aspect = cam.aspect;

		//这一步很关键,这句话的意思是让ReflectionCamera除了镜面本身不渲染,其他的物体都渲染
		//因为我们渲染的Rendtexture(镜面投影的纹理)是不能包含镜面本身的,因为这个脚本是挂在镜面本身身上的,如果渲染了镜面本身那么OnWillRenderObject在镜面本身被渲染时就会递归调用从而报错
		ReflectionCamera.cullingMask = ~(1<<LayerMask.NameToLayer ("Mirror"));


        //获得镜面的法向量Normal,因为此镜面是一个plane,所以法线就是transform.up
        Vector3 Normal = transform.up;
		//获得镜面上一点o的位置
		Vector3 o = transform.position;

		//这个d就是CalculateMirrorMatrix第二个参数Mirror的第四个分量(具体推倒过程看工程目录中的图)
		float d = Vector3.Dot (Normal, o);
		//Mirror的前3个分量的赋值为什么是Normal的xyz参考工程目录中的图
		Vector4 mirror = new Vector4(Normal.x,Normal.y,Normal.z,d);

		Matrix4x4 mirrorMatrix = Matrix4x4.zero;
		//因为第一个参数前有ref修饰,所以mirrorMatrix在CalculateMirrorMatrix被赋值
		CalculateMirrorMatrix (ref mirrorMatrix, mirror);

		//将投影相机的视矩阵在渲染之前和镜面矩阵相乘,这样渲染的时候摄像机所渲染的画面就是倒影的画面了,就好像是以镜面为中心,在与主相机对称的地方又放了一个摄像机来渲染倒影
		//在初始化的时候ReflectionCamera是完全复制cam的,所以初始化的cam.worldToCameraMatrix和ReflectionCamera.worldToCameraMatrix是一样的
		//因为这个方法每一帧都会调用,所以不能使用ReflectionCamera.worldToCameraMatrix*mirrorMatrix,因为这样ReflectionCamera.worldToCameraMatrix会一直重复的和mirrorMatrix相乘,所以我们用cam.worldToCameraMatrix代替
		ReflectionCamera.worldToCameraMatrix = cam.worldToCameraMatrix * mirrorMatrix;

		//在镜面空间中计算裁剪平面
		Vector4 ClipPlane = CameraSpacePlane (ReflectionCamera, o, Normal, 1.0f);

		//计算投影倾斜矩阵
		//通过裁剪平面计算投影矩阵,这里CalculateObliqueMatrix一定要主相机来调用,不然会报错
		//实际上这个倾斜投影矩阵的作用就是将摄像机原本的近裁剪面(Near)面替换为我们自己的镜面
		//Matrix4x4 Project_Matrix = cam.CalculateObliqueMatrix (ClipPlane);


		//使用自己的方法计算投影倾斜矩阵
		Matrix4x4 Project_Matrix = CalculateObliqueMatrix (ClipPlane,cam.projectionMatrix);

        //将新计算的投影矩阵(就是MVP中的P)赋值给镜面相机,作用为把镜面相机原本的近裁剪面(Near)面替换为我们自己的镜面
        ReflectionCamera.projectionMatrix = Project_Matrix;

		//如果这里不进行反转,影子看到的是错误的,看到的画面是物体内部的细节,而不是真正的倒影
		//因为我们通过镜面矩阵进行变换的时候仅仅是将顶点变换到镜面空间,但是法线并没有变换到镜面空间,所以倒影就不对了,使用底层的GL.invertCulling可以将渲染的画面反转一下
		GL.invertCulling = true;
		ReflectionCamera.Render ();
		//渲染完成后一定要反转回来
		GL.invertCulling = false;
	}

	//自己实现投影倾斜矩阵
	//参数1是裁剪平面(镜面),参数2是主相机的投影矩阵
	//这个矩阵的具体推倒过程很复杂,就不做出详细说明
	Matrix4x4 CalculateObliqueMatrix(Vector4 ClipPlane,Matrix4x4 projection)
	{
		Vector4 Q = projection.inverse * new Vector4 (sgn (ClipPlane.x), sgn (ClipPlane.y), 1, 1);

		float cq = Vector4.Dot (Q, ClipPlane);

		Vector4 C = 2.0f * ClipPlane / cq;

		projection.m20 = C.x;

		projection.m21 = C.y;

		projection.m22 = C.z + 1;

		projection.m23 = C.w;

		return projection;
	}

	float sgn(float x)
	{
		if (x > 0)
			return 1;
		if (x < 0)
			return -1;

		return 0;
	}

	//计算裁剪平面(即是我们的镜面),将顶点和法线变换到经过经过镜面矩阵变换后的空间中,从而计算出裁剪平面
	Vector4 CameraSpacePlane(Camera MirrorCam,Vector3 Originalpos,Vector3 Originalnormal,float sideSign)
	{
		//这个worldToCameraMatrix已经经过了镜面矩阵的变换
		Matrix4x4 cam_matrix = MirrorCam.worldToCameraMatrix;

		Vector3 MirrorPos = cam_matrix.MultiplyPoint (Originalpos);

		Vector3 MirrorNormal = cam_matrix.MultiplyVector (Originalnormal).normalized * sideSign;

		//裁剪平面
		return  new Vector4 (MirrorNormal.x, MirrorNormal.y, MirrorNormal.z, -Vector3.Dot (MirrorPos, MirrorNormal));
	}

	//计算镜面矩阵(具体推倒过程看工程目录中的图)
	void CalculateMirrorMatrix(ref Matrix4x4 mirrorMatrix,Vector4 Mirror)
	{
		mirrorMatrix.m00 = 1f - 2f * Mirror [0] * Mirror [0];
		mirrorMatrix.m01 = -2f * Mirror [0] * Mirror [1];
		mirrorMatrix.m02 = -2f * Mirror [0] * Mirror [2];
		mirrorMatrix.m03 = 2f * Mirror [0] * Mirror [3];

		mirrorMatrix.m10 = -2f * Mirror [0] * Mirror [1];
		mirrorMatrix.m11 = 1 - 2f * Mirror [1] * Mirror [1];
		mirrorMatrix.m12 = -2f * Mirror [1] * Mirror [2];
		mirrorMatrix.m13 = 2f * Mirror [1] * Mirror [3];

		mirrorMatrix.m20 = -2f * Mirror [0] * Mirror [2];
		mirrorMatrix.m21 = -2f * Mirror [2] * Mirror [1];
		mirrorMatrix.m22 = 1-2f * Mirror [2] * Mirror [2];
		mirrorMatrix.m23 = 2f * Mirror [2] * Mirror [3];

		mirrorMatrix.m30 = 0f;
		mirrorMatrix.m31 = 0f;
		mirrorMatrix.m32 = 0f;
		mirrorMatrix.m33 = 1f;
	}
}
