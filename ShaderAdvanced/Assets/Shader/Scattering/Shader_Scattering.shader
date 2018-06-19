Shader "Unlit/Shader_Scattering"
{
	Properties
	{
		_CubeTex ("CubeTex", cube) = "" {}
		_SpecValue("SpecValue",range(1,128)) = 64
		_FresnelOffset("FresnelOffset",range(0,1)) = 0.5
		_FresnelScale("FresnelScale",range(0,1)) = 0.5
		_FresnelPow("FresnelPow",range(1,5)) = 2
	}

	//这是一个色散(色散是自然界中常见的现象,如光通过三棱镜时会出现七种不同颜色的光,自然界中最常见的色散现象就是彩虹)的Shader
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
			#include "AutoLight.cginc"

			struct v2f
			{
				LIGHTING_COORDS(0,1)
				float3 refr_r:TEXCOORD2;
				float3 refr_g:TEXCOORD3;
				float3 refr_b:TEXCOORD4;
				float3 N:TEXCOORD5;
				float3 V:TEXCOORD6;
				float3 L:TEXCOORD7;
				float4 vertex : SV_POSITION;
			};

			samplerCUBE _CubeTex;
			float _SpecValue;
			float _FresnelOffset,_FresnelScale,_FresnelPow;

			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				float3 V = WorldSpaceViewDir(v.vertex);

				//折射函数refract的V参数是摄像机指向物体顶点,而 WorldSpaceViewDir(v.vertex)是从物体顶点指向摄像机,所以取负
				V = -normalize(V);

				o.V = -V;

				float3 N = mul(v.normal,unity_WorldToObject);

				N=normalize(N);

				o.N = N;

				o.L = normalize(WorldSpaceLightDir(v.vertex));

				//折射在r通道上的采样向量,0.96是散射率,越小则表示散射的越强,经验上来说红色通道的散射率应该是最大的,取0.96
				o.refr_r= refract(V,N,0.96);
				//折射在g通道上的采样向量
				o.refr_g= refract(V,N,0.98);
				//折射在b通道上的采样向量(b通道上的散射率为最小)
				o.refr_b= refract(V,N,1);

				TRANSFER_VERTEX_TO_FRAGMENT(o)

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;
				col.r = texCUBE(_CubeTex, i.refr_r).r;
				col.g = texCUBE(_CubeTex, i.refr_g).g;
				col.b = texCUBE(_CubeTex, i.refr_b).b;
				col.a = 1;

				//计算漫反射
				float diff = saturate(dot(i.N,i.L));

				UNITY_LIGHT_ATTENUATION(atten,i,i.vertex.xyz)

				float3 diffcol = diff*_LightColor0*atten;

				//计算高光
				//半角向量
				float3 H = normalize(normalize(i.L)+normalize(i.V));
				float3 SpecCol = _LightColor0 * saturate(pow(dot(i.N,H),_SpecValue));

				col.rgb = col.rgb + diffcol + SpecCol;

				//菲尼尔,我们不需要一定要按照公式来计算菲尼尔,这里改了一个参数,将V改为了H
				float fresnel = _FresnelOffset + _FresnelScale*pow(1+dot(-H,i.N),_FresnelPow);
				col = lerp(col,_LightColor0,fresnel);

				return col;
			}
			ENDCG
		}


		Pass
		{
			Tags { "lightmode"="forwardadd" }

			blend one one
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct v2f
			{
				LIGHTING_COORDS(0,1)
				float3 refr_r:TEXCOORD2;
				float3 refr_g:TEXCOORD3;
				float3 refr_b:TEXCOORD4;
				float3 N:TEXCOORD5;
				float3 V:TEXCOORD6;
				float3 L:TEXCOORD7;
				float4 vertex : SV_POSITION;
			};

			samplerCUBE _CubeTex;
			float _SpecValue;
			float _FresnelOffset,_FresnelScale,_FresnelPow;

			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				float3 V = WorldSpaceViewDir(v.vertex);

				//折射函数refract的V参数是摄像机指向物体顶点,而 WorldSpaceViewDir(v.vertex)是从物体顶点指向摄像机,所以取负
				V = -normalize(V);

				o.V = -V;

				float3 N = mul(v.normal,unity_WorldToObject);

				N=normalize(N);

				o.N = N;

				o.L = normalize(WorldSpaceLightDir(v.vertex));

				//折射在r通道上的采样向量,0.96是散射率,越小则表示散射的越强,经验上来说红色通道的散射率应该是最大的,取0.96
				o.refr_r= refract(V,N,0.96);
				//折射在g通道上的采样向量
				o.refr_g= refract(V,N,0.98);
				//折射在b通道上的采样向量(b通道上的散射率为最小)
				o.refr_b= refract(V,N,1);
				
				TRANSFER_VERTEX_TO_FRAGMENT(o)

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;
				col.r = texCUBE(_CubeTex, i.refr_r).r;
				col.g = texCUBE(_CubeTex, i.refr_g).g;
				col.b = texCUBE(_CubeTex, i.refr_b).b;
				col.a = 1;

				//计算漫反射（点光源）
				float diff = saturate(dot(i.N,i.L));
				
				UNITY_LIGHT_ATTENUATION(atten,i,i.vertex.xyz)
				
				float3 diffcol = diff*_LightColor0*atten;

				col.rgb = col.rgb + diffcol;

				//半角向量
				float3 H = normalize(normalize(i.L)+normalize(i.V));

				//菲尼尔,我们不需要一定要按照公式来计算菲尼尔,这里改了一个参数,将V改为了H
				float fresnel = _FresnelOffset + _FresnelScale*pow(1+dot(-H,i.N),_FresnelPow);
				col = lerp(col,_LightColor0,fresnel);

				return col;
			}
			ENDCG
		}
	}

	fallback "Diffuse"
}
