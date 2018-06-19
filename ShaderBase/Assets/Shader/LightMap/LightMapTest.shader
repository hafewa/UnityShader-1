// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable

Shader "Unlit/LightMapTest"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				float2 uv:TEXCOORD0;
				//添加一个对光照贴图的UV
				float2 uv_LightMap:TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			//光照贴图就存在这个变量中,Properties不需要声明,Unity帮我们做好了
			// sampler2D unity_Lightmap;

			//光照贴图的平铺偏移量存放在这个变量中,也是Unity帮我们做好了
			// float4 unity_LightmapST;
			
			v2f vert (appdata_full v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				//对主纹理做的平铺和偏移
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				o.uv_LightMap = v.texcoord1;

				//对于光照贴图进行的平铺和偏移
				//要想自定义的shader使用光照贴图这个平铺和偏移的操作必须要做,否则效果不正确
				//平铺
				o.uv_LightMap.x*=unity_LightmapST.x;
				o.uv_LightMap.y*=unity_LightmapST.y;

				//偏移
				o.uv_LightMap.x+=unity_LightmapST.z;
				o.uv_LightMap.y+=unity_LightmapST.w;

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				fixed4 col = tex2D(_MainTex,IN.uv.xy);

				fixed4 col_lightmap = tex2D(unity_Lightmap,IN.uv_LightMap);

				//光照贴图采样后还要进行解码
				float3 final_Lightmap_col = DecodeLightmap(col_lightmap);

				col.rgb*= final_Lightmap_col;

				return col;
			}
			ENDCG
		}
	}
}
