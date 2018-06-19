using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetGrabScreenRenderTexture : MonoBehaviour 
{
	public Renderer render;

	void Start ()
	{
		GameObject go = new GameObject ("ProjectorCam");

		Camera cam = go.AddComponent<Camera> ();

		cam.cullingMask = LayerMask.GetMask ("ShadowCast");

		//透视模式
		cam.fieldOfView = 60;
		cam.clearFlags = CameraClearFlags.SolidColor;
		cam.backgroundColor = new Color (1, 1, 1, 0);
		cam.transform.position = this.transform.position;
		cam.transform.rotation = this.transform.rotation;

		cam.transform.parent = this.transform;

		//注意这里是你Game视图分辨率用的是多大的分辨,这里就要使用多少分辨率的RenderTexture,因为我们是要替换GrabPass{}所抓取的整个屏幕的纹理_GrabTexture,所以这个RenderTexture应该和屏幕分辨率相同
		RenderTexture rt = new RenderTexture (1600, 600,0);
		rt.wrapMode = TextureWrapMode.Clamp;
		cam.targetTexture = rt;

		render.material.SetTexture ("_ProjectTexture", rt);

		//构造透视投影纹理矩阵
		Matrix4x4 normalMatrix = new Matrix4x4();
		normalMatrix.m00 = 0.5f;
		normalMatrix.m11 = 0.5f;
		normalMatrix.m22 = 0.5f;
		normalMatrix.m03 = 0.5f;
		normalMatrix.m13 = 0.5f;
		normalMatrix.m23 = 0.5f;
		normalMatrix.m33 = 1;

		//我们最终所要构建的矩阵是一个normalMatrix*projectionMatrix*worldToCameraMatrix*unity_ObjectToWorld(这个矩阵的效果是能通过摄像机将所看到的画面投射到一个平面上)
		//因为我们再C#中拿不到unity_ObjectToWorld,所以我们先在这里构建出normalMatrix*projectionMatrix*worldToCameraMatrix,再在Shader乘以unity_ObjectToWorld
		Matrix4x4 nPV = normalMatrix * GL.GetGPUProjectionMatrix(cam.projectionMatrix,false)*cam.worldToCameraMatrix;

		render.material.SetMatrix ("_ProjectMatrix", nPV);
	}
}
