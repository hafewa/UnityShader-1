Shader "复习/blinnPhone光照模型"
{
	Properties
	{
		_MainColor("MainColor",COLOR) = (1,1,1,1)
		_Specular("Specular",Range(1,255)) = 20
		_SpecluarColor("SpecluarColor",Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float3 normal:TEXCOORD0;
				float3 viewDir:TEXCOORD1;
				float3 lightDir:TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			fixed4 _MainColor;
			float _Specular;
			fixed4 _SpecluarColor;
			
			v2f vert (appdata_base v)
			{
				v2f o;

				float3 WorldNormal = UnityObjectToWorldNormal(v.normal);

				float3 WorldViewDir = normalize(WorldSpaceViewDir(v.vertex));

				float3 WorldLightDir = normalize(WorldSpaceLightDir(v.vertex));

				o.normal = WorldNormal;
				o.viewDir = WorldViewDir;
				o.lightDir = WorldLightDir;

				o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float Dot = saturate( dot(i.normal,i.lightDir));

				fixed4 col = UNITY_LIGHTMODEL_AMBIENT + _LightColor0 * Dot *_MainColor;
				float3 H = normalize(i.lightDir + i.viewDir);

				float SpecularValue = pow(saturate(dot(i.normal,H)),_Specular);

				col+=_SpecluarColor*SpecularValue;
				return col ;
			}
			ENDCG
		}
	}
}
