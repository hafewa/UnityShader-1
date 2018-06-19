// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/UVblurry"
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
				float z:TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata_base v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				//将顶点的深度值转换到世界坐标空间
				o.z = mul(unity_ObjectToWorld,v.vertex.z);

				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				//fixed4 col = tex2D(_MainTex,IN.uv);

//				//要进行模糊就要多次采样,每次采样在x或者y上加上点偏移就好
//				float2 uv = IN.uv;
//
//				//在x方向上向右偏移一点
//				uv.x += _BlurryValue;
//
//				fixed3 col_1 = tex2D(_MainTex,uv).rgb;
//
//				col.rgb += col_1;
//
//				//在x方向上向左偏移一点
//				uv.x -= _BlurryValue;
//				fixed3 col_2 = tex2D(_MainTex,uv).rgb;
//				col.rgb += col_2;
//
//				//在y方向上向右偏移一点
//				uv.y += _BlurryValue;
//				fixed3 col_3 = tex2D(_MainTex,uv).rgb;
//				col.rgb += col_3;
//
//				//在y方向上向左偏移一点
//				uv.y -= _BlurryValue;
//				fixed3 col_4 = tex2D(_MainTex,uv).rgb;
//				col.rgb += col_4;
//
//				//这里因为直接叠加的话会使得最终输出比较亮,所以叠加了几次就除以几次
//				col.rgb = col.rgb/5;


				//以上的做法的优点是适用于任何级别的硬件,但是这样做并不够精细
				//CG中有tex2D有一个重载函数可以直接根据导数来进行模糊采样,但是这个函数只支持target 3.0
				//第一个float2是在x轴上的导数即是UV在x轴的变化率
				//第二个float2是在y轴上的导数即是UV在y轴的变化率
				//fixed4 col = tex2D(_MainTex,IN.uv,float2(_X_1,_X_2),float2(_Y_1,_Y_2));

				//来做一个旋转时当摄像机正好转到正面的时候看到的面是清晰的,当不是正面时随着物体顶点的z值的导数(变化率)逐渐模糊的效果
				//求得物体顶点的深度值在x方向上的导数
				//ddx和ddy可以自动返回是float或者float(2-4)类型的返回值,它可以根据接收的变量类型来自动组织
				float2 Derivative_x = ddx(IN.z)*2;

				//求得物体顶点的深度值在y方向上的导数
				float2 Derivative_y = ddy(IN.z)*2;

				fixed4 col = tex2D(_MainTex,IN.uv,Derivative_x,Derivative_y);

				return col;
			}
			ENDCG
		}
	}
}
