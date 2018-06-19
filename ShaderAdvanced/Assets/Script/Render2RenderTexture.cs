using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Render2RenderTexture : MonoBehaviour 
{
	void Start () 
	{
		GameObject go = new GameObject ("ProjectorCam");

		Camera cam = go.AddComponent<Camera> ();

		cam.cullingMask = LayerMask.GetMask ("ShadowCast");

		//正交模式
		//cam.orthographic = true;
		//cam.orthographicSize = 5;

		//透视模式
		cam.fieldOfView = 60;
		cam.clearFlags = CameraClearFlags.SolidColor;
		cam.backgroundColor = new Color (1, 1, 1, 0);
		cam.transform.position = this.transform.position;
		cam.transform.rotation = this.transform.rotation;
		//摄像机的长宽比,当选用正交模式时
		cam.aspect = 1;
		cam.transform.parent = this.transform;
		RenderTexture rt = new RenderTexture (1024, 1024,0);
		rt.wrapMode = TextureWrapMode.Clamp;
		cam.targetTexture = rt;

        //这个方法的作用是将摄像机渲染的物体按照指定的Shader来渲染,第二个参数是Shader中的一个Tag,在渲染的物体本身的Shader中含有这个Tag才会被替换
        //比如本例,这个摄像机渲染的物体(并且物体本身的Shader中含有"RenderType"这个tag)的shader都会被"Custom/Shader_ProjectorShadow"的shader所替换
        //因为我们这个摄像机的mask是ShadowCast,而本例中的场景中只有一个cube的层是ShadowCast,并且cube是实体的,肯定含有"RenderType"="Opaque",所以只有这个cube会被替换
        //cam.SetReplacementShader (Shader.Find ("Custom/Shader_ProjectorDepthTexture"), "RenderType");

        //注释掉上面的代码是因为还有一种简单的方式,我们根本不需要这张深度纹理,我们就直接让投影相机渲染出一张物体本身的Rendertexture,因为投影相机的clearFlags为SolidColor,且背景色是(1, 1, 1, 0)
        //这样当Rendertexture中Alpha不为零的地方肯定就是物体的渲染部分,其他的地方都应该是0,根据这个原理我们在Shader中只要简单的判断Alpha是否为0就可以得到阴影

        //拿到投影相机的投影矩阵GL.GetGPUProjectionMatrix是针对各个不同的平台都能获得正确的投影矩阵

        //构造透视投影纹理矩阵,这里只是展示Unity Shader中自带的ComputeScreenPos的原理,实际上并用不上这个矩阵
        Matrix4x4 normalMatrix = new Matrix4x4();
		normalMatrix.m00 = 0.5f;
		normalMatrix.m11 = 0.5f;
		normalMatrix.m22 = 0.5f;
		normalMatrix.m03 = 0.5f;
		normalMatrix.m13 = 0.5f;
		normalMatrix.m23 = 0.5f;
		normalMatrix.m33 = 1;

        //我们最终所要构建的矩阵是一个normalMatrix*projectionMatrix*worldToCameraMatrix*unity_ObjectToWorld(这个矩阵的效果是能通过摄像机将所看到的画面投射到一个平面上,后面三个就是MVP)
        //因为我们再C#中拿不到unity_ObjectToWorld,所以我们先在这里构建出normalMatrix*projectionMatrix*worldToCameraMatrix,再在Shader乘以unity_ObjectToWorld
        Matrix4x4 PV =  GL.GetGPUProjectionMatrix(cam.projectionMatrix,false)*cam.worldToCameraMatrix;

		//为什么没有和normalMatrix相乘,其实Unity提供了一个ComputeScreenPos(float4 pos)的方法中包含了这个矩阵的效果
		//这里只是给出ComputeScreenPos的实现原理

		//设置Unlit/Shader_RealTimeShadow中的变量
		Shader.SetGlobalMatrix ("_ProjectMatrix", PV);
		Shader.SetGlobalTexture ("_ShadowTexture", rt);
	}
}
