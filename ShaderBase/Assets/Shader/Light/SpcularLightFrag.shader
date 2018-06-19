// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/SpcularLightFrag"
{
	Properties
	{
		_MainColor("MainColor",color) = (1,1,1,1)
		_HighLightColor("HighLightColor",color) = (1,1,1,1)
		_Shinness("Shinness",range(0,64)) = 8
	}
	SubShader
	{
		tags{"LightMode" = "ForwardBase"}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "lighting.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				float4 vertex:TEXCOORD0;
				float3 normal:TEXCOORD1;
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.vertex = v.vertex;

				o.normal = v.normal;

				return o;
			}

			float4 _MainColor;
			float4 _HighLightColor;
			float _Shinness;
			
			fixed4 frag (v2f IN) : COLOR
			{
				//漫反射+环境光
				fixed4 col = UNITY_LIGHTMODEL_AMBIENT;

				float3 L = normalize( WorldSpaceLightDir(IN.vertex));

				float3 N = UnityObjectToWorldNormal(IN.normal);

				float3 V = normalize(WorldSpaceViewDir(IN.vertex));

				float diff = saturate(dot(N,L));

				col += _MainColor * _LightColor0 * diff;

				//镜面反射(phone)
				//float3 R = 2*dot(N,L)*N -L;

				//镜面系数
				//float SpecularValue = saturate(dot(R,V));

				//col += _HighLightColor * pow(SpecularValue,_Shinness);


				//镜面反射(blinnPhone)

				//半角向量
				float3 H = L + V;

				H = normalize(H);

				float SpecularValue = saturate(dot(H,N));

				col +=  _HighLightColor * pow(SpecularValue,_Shinness);

				float3 wpos = mul(unity_ObjectToWorld,IN.vertex);

				//要使得点光源有效果就要使用这个函数,不过这个函数只能在ForwardBase里把点光源按照逐顶点处理,要想使用更加平滑的逐像素处理,就要添加ForwardAdd,使用了ForwardAdd,这里这个函数就要删掉,不然重复叠加逐顶点和逐像素,效果不对
				float3 PointLightColor = Shade4PointLights(unity_4LightPosX0,unity_4LightPosY0,unity_4LightPosZ0,
												unity_LightColor[0].rgb,unity_LightColor[1].rgb,
												unity_LightColor[2].rgb,unity_LightColor[3].rgb
												,unity_4LightAtten0,wpos,N);

				col.rgb+=PointLightColor;

				return col;
			}
			ENDCG
		}
	}
}
