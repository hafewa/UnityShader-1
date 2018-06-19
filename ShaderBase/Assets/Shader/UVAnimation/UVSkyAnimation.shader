Shader "Unlit/UVSkyAnimation"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_A("A",range(0,0.1)) = 0.01
		_F("F",range(1,5)) = 1
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

			#include "UnityCg.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				float2 uv:TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _A;
			float _F;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				float2 uv = IN.uv;

				//利用三角函数进行周期性的变化
				float uv_offset = _A * sin(uv *_F+ _Time.x * 2);

				uv+=uv_offset;

				fixed4 col_1 = tex2D(_MainTex,uv);

				//做第二次采样,将uv重新复制为原始uv,这一次是减,这样最终效果就会有两层相互交错的星空移动效果
				uv = IN.uv;

				uv-=uv_offset;
					
				fixed4 col_2 = tex2D(_MainTex,uv);

				//相加之后应该除以2,否则比较亮
				return (col_1+col_2)/2;
			}
			ENDCG
		}
	}
}
