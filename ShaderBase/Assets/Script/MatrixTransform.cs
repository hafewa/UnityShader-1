using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatrixTransform : MonoBehaviour 
{
	
	// Update is called once per frame
	void Update () 
	{
		//UNITY_MATRIX_MVP并不是字面意思的矩阵相乘顺序,实际上是下面的顺序

		//Camera.main.projectionMatrix 投影矩阵
		//Camera.main.worldToCameraMatrix 摄像机矩阵
		//transform.localToWorldMatrix世界矩阵
		Matrix4x4 mvp = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix * transform.localToWorldMatrix;

		//旋转矩阵
		Matrix4x4 RM = new Matrix4x4();

		//沿Y轴旋转的矩阵
		RM [0, 0] = Mathf.Cos (Time.realtimeSinceStartup);
		RM [0, 2] = Mathf.Sin (Time.realtimeSinceStartup);
		RM [1, 1] = 1;
		RM [2, 0] = -Mathf.Sin (Time.realtimeSinceStartup);
		RM [2, 2] = Mathf.Cos (Time.realtimeSinceStartup);
		RM [3, 3] = 1;

		//缩放矩阵
		Matrix4x4 SM = new Matrix4x4();
		//这里除以4再加上0.5是为了把缩放的大小限制在大于0且比较小的范围内
		SM [0, 0] = Mathf.Cos (Time.realtimeSinceStartup) / 4 + 0.5f;
		//更小的正整数范围
		SM [1, 1] = Mathf.Sin (Time.realtimeSinceStartup) / 8 + 0.5f;

		SM [2, 2] = Mathf.Cos (Time.realtimeSinceStartup) / 6 + 0.5f;

		SM [3, 3] = 1;

		//this.GetComponent<Renderer> ().material.SetMatrix ("mvp", mvp);

		this.GetComponent<Renderer> ().material.SetMatrix ("rm", RM);

		this.GetComponent<Renderer> ().material.SetMatrix ("sm", SM);
	}
}
