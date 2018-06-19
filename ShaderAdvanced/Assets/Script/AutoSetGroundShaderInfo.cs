using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoSetGroundShaderInfo : MonoBehaviour {


	void Start () 
	{
		//拿到当前激活的地形
		Terrain T = Terrain.activeTerrain;

		Material mat = T.materialTemplate;
	
		TerrainData t_data = T.terrainData;

		//当前地形的控制纹理
		Texture2D[] controllerTexs = t_data.alphamapTextures;

		//这个就是当前地形所使用到的纹理列表
		SplatPrototype[] Splats = t_data.splatPrototypes;

		//shader中使用了全局的纹理变量,shader会自动对那些纹理变量赋值,我们就不需要在赋值了(这几个全局变量只针对地形系统,名字一定要写对)
		//mat.SetTexture ("_Control", controllerTexs [0]);
		//mat.SetTexture ("_Splat0", Splats [0].texture);
		//mat.SetTexture ("_Splat1", Splats [1].texture);
		//mat.SetTexture ("_Splat2", Splats [2].texture);
		//mat.SetTexture ("_Splat3", Splats [3].texture);

		//只需要赋值剩下的不是全局变量的贴图
		mat.SetTexture ("_Control_1", controllerTexs[1]);
		mat.SetTexture ("_Splat4", Splats[4].texture);
		mat.SetTexture ("_Splat5", Splats[5].texture);
	}
}
