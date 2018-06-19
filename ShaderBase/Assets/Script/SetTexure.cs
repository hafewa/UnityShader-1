using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetTexure : MonoBehaviour 
{

	public float tiling_x;
	public float tiling_y;
	public float offset_x;
	public float offset_y;


	void Update () 
	{
		GetComponent<Renderer> ().material.SetFloat ("_tiling_x", tiling_x);
		GetComponent<Renderer> ().material.SetFloat ("_tiling_y", tiling_y);
		GetComponent<Renderer> ().material.SetFloat ("_offset_x", offset_x);
		GetComponent<Renderer> ().material.SetFloat ("_offset_y", offset_y);
	}
}
