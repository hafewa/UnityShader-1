using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetGrassMousePos : MonoBehaviour {

	private Material mat;
	void Start () 
	{
		//拿到当前激活的地形
		Terrain T = Terrain.activeTerrain;
		Material mat = T.materialTemplate;
	}
	

	void Update ()  
	{
		if (Input.GetMouseButton (0)) 
		{
			Ray ray = Camera.main.ScreenPointToRay (Input.mousePosition);

			RaycastHit hit;

			if (Physics.Raycast (ray, out hit)) 
			{
				Vector3 hitPos = hit.point;

				Vector4 v = new Vector4 (hitPos.x, hitPos.y, hitPos.z, 0);
				//设置Shader的全局变量,任何Shader中如果还有float4的_GrassPointPos都会被设置
				Shader.SetGlobalVector("_GrassPointPos",v);
			}
		}
	}
}
