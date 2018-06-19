Shader "Unlit/MyDiffuseNormalMap"
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
			Tags { "lightmode"="forwardbase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				float2 uv:TEXCOORD1;
				float3 lightDir:TEXCOORD2;
			};

			sampler2D _MainTex;
			sampler2D _BumpTex;
			
			v2f vert (appdata_tan v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.uv = v.texcoord;

				float3 N = normalize(v.normal);

				//切线,在顶点片段Shader中要想使得法线贴图最终呈现出正确的结果,就需要把光向量转换到切线坐标系(切空间)中(相对模型的每个面的坐标系)
				//因为如果不这样做最终从法线贴图中同一个UV坐标采样的normal是一样的,但是在模型的不同面上存在相同UV的采样,这样这些相同UV采样的点的法向量就会一样,这样是不正确的,如背对着我们的面法线就应该是负的,但是法线一样的话就不是负的了
				//切线坐标系矩阵(又称作纹理矩阵)为该点的切线,原本的法线,切线,以及垂直于法线和切线组成的面的向量binNormal所组成的矩阵Tan_Matrix
				float3 T = normalize(v.tangent.xyz);

				//垂直于切线和法线的向量
				float3 binNormal = cross(N,T);

				//矩阵,在UnityCG.inc中已经提供了计算这个矩阵的宏TANGENT_SPACE_ROTATION,最终得到一个float3x3的rotation矩阵
				float3x3 Tan_Matrix = float3x3(T,binNormal,N);

				//将光向量转换到切线坐标系
				o.lightDir = normalize(mul(Tan_Matrix,_WorldSpaceLightPos0));

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				//法线不是从系统传进来的,而是从法线贴图获取的,并且跟光计算漫反射的时候就必须使用这个纹理矩阵Tan_Matrix与光照相乘,否则会出现不对的效果
				fixed3 N = normalize(UnpackNormal(tex2D(_BumpTex,IN.uv)));

				float Dot = saturate(dot(N,IN.lightDir));

				fixed4 col = tex2D(_MainTex,IN.uv);

				col = col * _LightColor0 * Dot;

				return col+UNITY_LIGHTMODEL_AMBIENT;
			}
			ENDCG
		}

		Pass
		{
			blend one one
			Tags { "lightmode"="forwardadd" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"


			struct v2f
			{
				float4 pos:POSITION;
				float2 uv:TEXCOORD0;
				float3 lightDir:TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _BumpTex;
			
			v2f vert (appdata_tan v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.uv = v.texcoord;

				float3 N = normalize(v.normal);

				//切线,在顶点片段Shader中要想使得法线贴图最终呈现出正确的结果,就需要把光向量转换到切线坐标系中(相对模型的每个面的坐标系)
				//因为如果不这样做最终从法线贴图中同一个UV坐标采样的normal是一样的,但是在模型的不同面上存在相同UV的采样,这样这些相同UV采样的点的法向量就会一样,这样是不正确的,如背对着我们的面法线就应该是负的,但是法线一样的话就不是负的了
				//切线坐标系矩阵为该点的切线,原本的法线和垂直于该点的法线和切线所形成的面的向量组合而成的矩阵
				float3 T = normalize(v.tangent.xyz);

				//垂直于切线和法线的向量
				float3 binNormal = cross(N,T);

				//矩阵
				float3x3 Tan_Matrix = float3x3(T,binNormal,N);

				//将光向量转换到切线坐标系
				o.lightDir = mul(Tan_Matrix,_WorldSpaceLightPos0);

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				fixed3 N = normalize(UnpackNormal(tex2D(_BumpTex,IN.uv)));
				float L = normalize(IN.lightDir);
				float Dot = saturate(dot(N,L));

				fixed4 col = tex2D(_MainTex,IN.uv);

				float atten = 0;

				//非平行光的简单衰减算法,_WorldSpaceLightPos0.w为0就是平行光
				if(_WorldSpaceLightPos0.w != 0)
				{
					//衰减算法
					atten = 1.0/length(IN.lightDir);
				}

				col = col * _LightColor0 * atten;

				return col;
			}
			ENDCG
		}
	}
}
