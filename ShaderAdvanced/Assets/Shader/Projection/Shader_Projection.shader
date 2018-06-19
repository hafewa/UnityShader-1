Shader "Custom/Shader_Projection"
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
				float4 Projection_uv : TEXCOORD0;
				float4 pos:POSITION;
			};

			sampler2D _MainTex;
			
			v2f vert (appdata_base v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				//原先的按照模型顶点来采样纹理的话不管模型有多小,整张纹理都会显示在模型上
				//透视纹理矩阵的算法,整个屏幕会把整张纹理图给铺满,模型占据屏幕的哪一部分区域,就显示这张纹理对应的区域,采样不再使用原先的模型的顶点坐标(0,1)来采样纹理了
				//float ux = o.pos.x *0.5 + o.pos.w*0.5;
				//float uy = o.pos.y *0.5 + o.pos.w*0.5;

				//o.Projection_uv = float4(ux,uy,o.pos.z,o.pos.w);

				//利用Unity的内置函数来达到同样的效果
				//记住参数一定是经过MVP变换后的pos
				o.Projection_uv = ComputeScreenPos(o.pos);

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				//透视除法,将投影空间变换到屏幕空间
				//这个不能少
				//float2 uv = IN.Projection_uv.xy/IN.Projection_uv.w;

				//效果和上面一样,tex2Dproj封装了透视除法
				fixed4 col = tex2Dproj(_MainTex, IN.Projection_uv);

				return col;
			}
			ENDCG
		}
	}
}
