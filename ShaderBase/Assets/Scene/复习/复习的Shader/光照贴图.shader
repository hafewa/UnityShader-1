// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "复习/光照贴图"
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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float2 uv_lightmap:TEXCOORD1;
			};

			sampler2D _MainTex;

			float4 _MainTex_ST;
			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				//光照贴图采样uv
				o.uv_lightmap = v.texcoord1;

				//光照贴图平铺
				o.uv_lightmap.x *= unity_LightmapST.x;//unity_LightmapST系统内部变量,用来控制光照贴图的平铺和偏移
				o.uv_lightmap.y *= unity_LightmapST.y;

				//光照贴图平移
				o.uv_lightmap.x+=unity_LightmapST.z;
				o.uv_lightmap.y+=unity_LightmapST.w;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				//对光照贴图进行采样并进行解码(因为烘培出来的光照贴图是加密的)
				fixed3 lightmap_col = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap,i.uv_lightmap));//unity_Lightmap系统内部变量,就是光照贴图纹理

				col.rgb = col.rgb * lightmap_col;

				return col;
			}
			ENDCG
		}
	}
}
