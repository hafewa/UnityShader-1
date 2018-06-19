Shader "复习/漫反射"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCg.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				fixed4 col:COLOR;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				float3 N = UnityObjectToWorldNormal(v.normal);
				float3 L = normalize(WorldSpaceLightDir(v.vertex));

				float Dot = saturate(dot(N,L));

				fixed4 col = UNITY_LIGHTMODEL_AMBIENT;
				col += _LightColor0 * Dot;
				o.col = col;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				col =col * i.col;

				return col;
			}
			ENDCG
		}
	}
}
