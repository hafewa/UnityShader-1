Shader "复习/转换到切空间的法线材质"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BumpTex("BumpTex",2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			tags { "LightMode" = "ForwardBase" }//平行光
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 lightDir:TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _BumpTex;
			
			v2f vert (appdata_tan v)
			{
				v2f o;
				float3 N = normalize(v.normal);//单位化法线
				float3 T = normalize(v.tangent.xyz);//单位化切线

				float3 B = cross(N,T);//垂直于法向量和切向量所组成的面的向量

				float3x3 Tan_Matrix = float3x3(T,B,N);//切空间矩阵

				o.lightDir = normalize(mul(Tan_Matrix,_WorldSpaceLightPos0));//将光照转换到切空间

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 N = normalize(UnpackNormal(tex2D(_BumpTex,i.uv)));

				float Dot = saturate(dot(N,i.lightDir));

				fixed4 col = tex2D(_MainTex, i.uv);

				col = col * _LightColor0 * Dot;
				return col + UNITY_LIGHTMODEL_AMBIENT;
			}
			ENDCG
		}

		Pass
		{
			blend one one//遗漏这个的话上面的pass完全无效
			tags { "LightMode" = "ForwardAdd" }//点光源
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 lightDir:TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _BumpTex;
			
			v2f vert (appdata_tan v)
			{
				v2f o;
				float3 N = normalize(v.normal);//单位化法线
				float3 T = normalize(v.tangent.xyz);//单位化切线

				float3 B = cross(N,T);//垂直于法向量和切向量所组成的面的向量

				float3x3 Tan_Matrix = float3x3(T,B,N);//切空间矩阵

				o.lightDir = normalize(mul(Tan_Matrix,_WorldSpaceLightPos0));//将光照转换到切空间

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 N = normalize(UnpackNormal(tex2D(_BumpTex,i.uv)));

				float Dot = saturate(dot(N,i.lightDir));

				fixed4 col = tex2D(_MainTex, i.uv);

				col = col * _LightColor0 * Dot;

				float atten = 0;

				if(_WorldSpaceLightPos0.w != 0)
				{
					atten = 1.0/length(i.lightDir);
				}

				col = col * atten;

				return col + UNITY_LIGHTMODEL_AMBIENT;
			}
			ENDCG
		}
	}
}
