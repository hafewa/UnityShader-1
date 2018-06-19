using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class CheckVertex : MonoBehaviour 
{

	public MeshFilter mf;

	void Start () 
	{
		Vector3[] verts = mf.mesh.vertices;

		float max_z = verts.Max (v =>v.z);

		float min_z = verts.Min (v => v.z);

		Debug.Log (max_z + "      " + min_z);
	}

	void Update ()
	{
		transform.Rotate (Vector3.up * Time.deltaTime * 10);
	}
}
