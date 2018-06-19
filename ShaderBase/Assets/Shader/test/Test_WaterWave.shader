Shader "Test/WaterWave"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_F("F",range(10,50)) = 10

		_A("A",range(0,0.1)) = 0.01

		_R("R",range(0,1)) = 0
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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;

				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _F, _A, _R;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//距离中心的距离
				float dis = distance(i.uv, float2(0.5,0.5));

				float sacle = 0;

				if (dis < _R)
				{
					//振幅
					_A*= 1 - dis / _R;

					sacle = _A *sin(-dis * 3.14 *_F + _Time.y * 10);

					i.uv += sacle;
				}

				sacle = saturate(sacle);

				fixed4 col = tex2D(_MainTex, i.uv);

				return col;
			}
			ENDCG
		}
	}
}
