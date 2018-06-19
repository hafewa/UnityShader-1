using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetPosition : MonoBehaviour 
{
	private Material mat;

	void Start () 
	{
		mat = GetComponent<Renderer> ().material;
	}


	void Update () 
	{
		mat.SetFloat ("_Pos_x", transform.position.x);
		mat.SetFloat ("_Pos_y", transform.position.y);
		mat.SetFloat ("_Pos_z", transform.position.z);
	}
}
