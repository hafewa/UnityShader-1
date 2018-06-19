Shader "Unlit/Tex_0"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_U("U",range(-0.1,0.1)) = 0
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

			struct v2f
			{
				float4 pos:POSITION;
			};

			sampler2D _MainTex;
			float _U;
			
			v2f vert (appdata_base v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				//_MainTex寻址模式为Clamp时(当_U为负时)为红色,因为该模式并不会将贴图重复排列起来,当uv坐标超过（0-1）的范围时它依然会以0来采样
				//_MainTex寻址模式为Repeat时为红色,颜色为绿色,因为此时采样的模式会将贴图重复排列起来,这样会寻址到紧挨着该贴图左边的贴图,而这张贴图的右边为绿色,所以当U坐标为-0.1时采样的是绿色
				//_MainTex过滤模式为point的时候,当拖动_U颜色只会瞬间变成红色或者绿色,没有渐变的过程
				//_MainTex过滤模式为Bilinear或者Trilinear的时候当拖动_U颜色会从绿色渐变到红色或者从红色渐变到绿色
				//Bilinear或者Trilinear的过滤模式,当采样时UV坐标在很小的范围内变化时(不够一个像素变化的变化),这个时候系统会从当前像素周围相邻的四个像素进行插值的运算从而得到最终的采样
				fixed4 col = tex2D(_MainTex,float2(_U,0.1));

				return col;
			}
			ENDCG
		}
	}
}
