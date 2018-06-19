Shader "复习/UV星空动画"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_A("A",Range(0,0.1)) = 0
		_F("F",Range(1,5)) = 1
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
			float _A;
			float _F;
		
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{	
				float2 uv = i.uv;
				float Offset_uv = _A*sin(uv* 3.14*_F+_Time.x*2);
				uv+=Offset_uv;
				fixed4 col_1 = tex2D(_MainTex,uv);
				uv = i.uv;
				uv-=Offset_uv;
				fixed4 col_2 = tex2D(_MainTex,uv);
				return (col_1 + col_2)/2;
			}
			ENDCG
		}
	}
}
