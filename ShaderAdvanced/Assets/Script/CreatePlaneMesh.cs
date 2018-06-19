using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreatePlaneMesh : MonoBehaviour 
{

	int size = 200;
	void Start () 
	{
		Vector3[] vertices = new Vector3[size * size];
		Vector2[] uvs = new Vector2[size * size];

		for (int z = 0; z < size; z++) 
		{
			for (int x = 0; x < size; x++) 
			{
				vertices [z * size + x] = new Vector3 (x * 0.05f, 0, z * 0.05f);
				uvs [z * size + x] = new Vector2 (x * 1.0f/size,z *1.0f/size);
			}
		}

		Mesh ms = new Mesh ();
		ms.vertices = vertices;
		ms.uv = uvs;
		ms.triangles = getTrianges ();

		GetComponent<MeshFilter> ().mesh = ms;
	}
	

	int[] getTrianges () 
	{
		int index = 0;

		//200*200的顶点所构成的每个像素(四边形)是199*199个,每一个像素又有两个三角形,两个三角形又是6个顶点
		int[] Trianges = new int[(size - 1) * (size - 1) * 6];

		//根据顺时针书算法
		for (int z = 0; z < size-1; z++) 
		{
			for (int x = 0; x < size-1; x++) 
			{
				Trianges [index++] = (z * size) + x;
				Trianges [index++] = ((z +1)* size) + x;
				Trianges [index++] = (z* size) + x+1;

				Trianges [index++] = ((z +1)* size) + x;
				Trianges [index++] = ((z +1)* size) + x+1;
				Trianges [index++] = (z* size) + x+1;
			}
		}

		return Trianges;
	}
}
