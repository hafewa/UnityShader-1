Shader "Test/Test_Rim"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_Rimvalue("Rimvalue",range(1,8)) = 1

		_OutLineColor("OutLineColor",color) = (1,1,1,1)
		_OutLineScale("OutLineScale",range(0,1)) = 0.01
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		pass
		{
			cull front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			float _OutLineScale;

			v2f vert (appdata_base v)
			{
				v.vertex.xyz+=v.normal*_OutLineScale;

				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = fixed4(0,0,0,1);

				return col;
			}

			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
		

			struct v2f
			{
				float2 uv : TEXCOORD0;
				//float3 N:TEXCOORD1;
				//float3 V:TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _Rimvalue;
			fixed4 _OutLineColor;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				//计算世界空间的法向量
				//o.N = UnityObjectToWorldNormal(v.normal);

				//o.V = WorldSpaceViewDir(v.vertex);

				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				
				fixed4 col = tex2D(_MainTex, i.uv);

//				float3 N = normalize(i.N);
//
//				float3 V = normalize(i.V);
//
//				float NdotV = saturate( dot(N,V));
//
//				float Rim = 1- NdotV;
//
//				fixed4 RimColor = pow(Rim,_Rimvalue)*_OutLineColor;

				//col+=RimColor;

				return col;
			}
			ENDCG
		}
	}
}
