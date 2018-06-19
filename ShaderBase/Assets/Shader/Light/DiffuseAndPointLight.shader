// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
Shader "Sbin/DiffuseAndPointLight"
{
	SubShader
	{
		
		Pass
		{
			//漫反射光照的光照模式ForwardBase
			tags{"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "lighting.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				fixed4 color:COLOR;
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;

				float3 N = normalize(v.normal);

				//将法线变换到世界空间的标准写法
				N = mul(float4(N,0),unity_WorldToObject).xyz;

				float3 L = normalize(_WorldSpaceLightPos0).xyz;

				float Dot = saturate(dot(N,L));

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.color = _LightColor0 * Dot;

				float3 wpos = mul(unity_ObjectToWorld,v.vertex);



				//仅仅只能在Vertex光照模型下才能使用的方法
				//o.color.rgb = ShadeVertexLights(v.vertex,v.normal);

				//仅仅只在ForwardBase光照模型下才能使用的方法
				o.color.rgb += Shade4PointLights(unity_4LightPosX0,unity_4LightPosY0,unity_4LightPosZ0,
												unity_LightColor[0].rgb,unity_LightColor[1].rgb,
												unity_LightColor[2].rgb,unity_LightColor[3].rgb
												,unity_4LightAtten0,wpos,N);

				return o;

			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				return IN.color + UNITY_LIGHTMODEL_AMBIENT;
			}
			ENDCG
		}
	}
}
