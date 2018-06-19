Shader "复习/投影与接收阴影"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass//平行光
		{
			tags { "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD2;
				float4 vertex:TEXCOORD4;
				float3 normal:TEXCOORD3;
				float4 LightDir:Color;
				float4 pos : SV_POSITION;
				LIGHTING_COORDS(0,1)//声明接收阴影的变量
			};

			sampler2D _MainTex;
			
			v2f vert (appdata_base v)
			{
				v2f o;

				float3 N =  UnityObjectToWorldNormal(v.normal);

				float3 L = normalize(WorldSpaceLightDir(v.vertex));
				o.LightDir.xyz = L;
				o.normal = N;

				o.vertex = mul(unity_ObjectToWorld,v.vertex);

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.uv = v.texcoord;
				TRANSFER_VERTEX_TO_FRAGMENT(o)//将接收阴影的数据传递到片段着色器中
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float dotValue = saturate(dot(i.normal,i.LightDir));

				fixed4 col = tex2D(_MainTex, i.uv)*_LightColor0*dotValue;

				UNITY_LIGHT_ATTENUATION(atten,i,i.vertex.xyz)//计算接收的阴影
				return (col + UNITY_LIGHTMODEL_AMBIENT) * atten;
			}
			ENDCG
		}

		Pass//点光源
		{
			Tags { "LightMode" = "ForwardAdd" }
			blend one one//既支持平行光又支持点光源
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd_fullshadows
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD2;
				float4 vertex:TEXCOORD4;
				float3 normal:TEXCOORD3;
				float4 LightDir:Color;
				float4 pos : SV_POSITION;
				LIGHTING_COORDS(0,1)//声明接收阴影的变量
			};

			sampler2D _MainTex;
			
			v2f vert (appdata_base v)
			{
				v2f o;

				float3 N =  UnityObjectToWorldNormal(v.normal);

				float3 L = normalize(WorldSpaceLightDir(v.vertex));
				o.LightDir.xyz = L;
				o.normal = N;

				o.vertex = mul(unity_ObjectToWorld,v.vertex);

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.uv = v.texcoord;
				TRANSFER_VERTEX_TO_FRAGMENT(o)//将接收阴影的数据传递到片段着色器中
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float dotValue = saturate(dot(i.normal,i.LightDir));

				fixed4 col = tex2D(_MainTex, i.uv)*_LightColor0*dotValue;

				UNITY_LIGHT_ATTENUATION(atten,i,i.vertex.xyz)//计算接收的阴影
				return (col + UNITY_LIGHTMODEL_AMBIENT) * atten;
			}
			ENDCG
		}
	}

	fallback "Diffuse"//投影只需要这一句就行
}
