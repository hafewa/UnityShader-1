 Shader "Unlit/Tex_Tiling_Offset"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
				float2 uv:TEXCOORD0;
			};

			sampler2D _MainTex;

//			//平铺和偏移量(从C#脚步中获取)
//			float _tiling_x;
//			float _tiling_y;
//			float _offset_x;
//			float _offset_y;

			//Unity本身提供了平铺偏移量是一个float4的数据,就是上面的一个集合,写法为纹理的名字加上_ST(S是指平铺,T指偏移)
			//没有这个变量的话Shader面板上的Tiling和offset都是没有效果的
			//注意要使用这个平铺偏移_MainTex的寻址模式要为repeat,否则效果不正确
			float4 _MainTex_ST;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				//o.uv = v.texcoord;

				//根据repeat寻址模式当uv大于1时便会从开始的地方重复采样
				//平铺
//				o.uv.x*= _MainTex_ST.x;
//				o.uv.y*= _MainTex_ST.y;
//
//				//偏移
//				o.uv.x+=_MainTex_ST.z;
//				o.uv.y+=_MainTex_ST.w;

				//上面的写法在UnityCG中有宏为,该宏没有;
				//没有这个写法的话Shader面板上的Tiling和offset都是没有效果的
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				fixed4 col = tex2D(_MainTex,IN.uv);

				return col;
			}
			ENDCG
		}
	}
}
