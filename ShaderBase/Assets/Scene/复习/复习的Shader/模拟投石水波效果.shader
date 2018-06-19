Shader "复习/模拟投石水波效果"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_A("A",Range(0.025,1)) = 0.1
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
			sampler2D _WaveTex;
			float _A;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//C#中传过来的波形纹理采样,在C#中只设置了_WaveTex的rg两个通道数据
				float2 rg = tex2D(_WaveTex,i.uv).rg;

				//颜色数据范围是(0,1)，uv的偏移应该是有正有负,所有将rg的数据转换到(-1,1)之间
				rg = rg *2-1;

				//得到的数据和自定义的波峰相乘
				rg*=_A;

				//主纹理偏移
				i.uv += rg;

				//对主纹理采样
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
