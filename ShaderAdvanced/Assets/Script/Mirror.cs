using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mirror : MonoBehaviour 
{
	public Transform RealObject;

	void Start () 
	{
		//这个就是单位化之后的镜面的法向量
		Vector3 N = transform.up;

		//RealObject指向镜面的向量
		Vector3 Po = transform.position - RealObject.position;

		//RealObject到镜面的距离
		float D = Vector3.Dot (-N, Po);

		GameObject VirtualObject = GameObject.CreatePrimitive (PrimitiveType.Sphere);

		//沿着法向量的反向量平移2*D
		VirtualObject.transform.position = RealObject.position -  N *D * 2;

	}
}
