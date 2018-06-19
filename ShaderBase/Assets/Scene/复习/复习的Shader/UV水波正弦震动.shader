Shader "复习/UV水波正弦震动"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_A("A",Range(0,0.1)) = 0.01
		_F("F",Range(10,50)) = 10
		_R("R",Range(0,1)) = 0
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
			float _A;
			float _F;
			float _R;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float dis = distance(i.uv,float2(0.5,0.5));
				float salce  = 0;
				if(dis < _R)
				{
					//这里为什么是乘法(因为1- dis/_R是一个小于1的值,而乘以一个小于1的数就会使得振幅更弱,波的能量也更小更柔和点)
					_A*= 1- dis/_R;
					salce = _A * sin(-dis*3.14* _F + _Time.y * 10);
					i.uv += salce;
				}

				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
