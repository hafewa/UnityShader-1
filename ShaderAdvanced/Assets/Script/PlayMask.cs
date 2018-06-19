using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayMask : MonoBehaviour 
{
	public Renderer[] rends;

	void Update () 
	{
		Vector3 o = transform.position;

		//这里取负时因为镜面的渲染是使用了镜面矩阵变换后的投影纹理来渲染的,所以镜面的法线取反才能有正确的结果
		Vector3 n = -transform.up;

		//设置需要被镜面裁剪的物体的Shader参数
		for (int i = 0; i < rends.Length; i++) 
		{
			rends [i].material.SetVector ("_o", o);
			rends [i].material.SetVector ("_n", n);
		}
	}
}
