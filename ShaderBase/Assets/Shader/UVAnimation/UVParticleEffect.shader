Shader "Unlit/UVParticleEffect"
{
	Properties
	{
		_MainTex ("MainTex", 2D) = "white" {}
		_SecondTex ("SecondTex", 2D) = "white" {}
		_A("A",range(0,0.1)) = 0.01
		_F("F",range(1,5)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			//只允许红色和黄色通道输出
			colormask rg
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				float2 uv:TEXCOORD0;
			};

			sampler2D _MainTex;
			sampler2D _SecondTex;
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
				//采样主纹理不做变化
 				fixed4 col = tex2D(_MainTex,IN.uv);

 				float2 uv = IN.uv;

 				//将第二张纹理按照正弦采样（正向的）
 				float  uv_offset = _A * sin(uv*_F + _Time.x *3);

 				uv+= uv_offset;

 				fixed4 col_1 = tex2D(_SecondTex,uv);

 				//主纹理和第二张纹理混合,因为第二张纹理中的蓝色通道占据较大比例,而其他的部分都是黑的,这样乘过以后最终效果是第二张纹理中黑的部分被完全融合成黑的（因为黑的部分b为0）,只有亮的地方两张图进行了混合
 				//形成了一种星空的动态粒子效果
 				col*= col_1.b;

 				uv = IN.uv;

 				uv-= uv_offset;

 				//将第二张纹理再来一次正弦采样(反向的)
 				fixed4 col_2 = tex2D(_SecondTex,uv);

 				col*= col_2.b;

 				return col*3;
			}
			ENDCG
		}
	}
}
