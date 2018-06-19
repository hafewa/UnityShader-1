Shader "Unlit/Transparent_ThrowWall"
{
	SubShader
	{
		//这个pass是渲染上边的没有被墙挡住的部分
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
			
			v2f vert (appdata_base v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				return fixed4(0,0,1,1);
			}
			ENDCG
		}

		//这个pass是渲染下面的被墙挡住的部分
		//上下两个pass最好不要颠倒,如果颠倒上面pass渲染下面被墙挡住部分的时候会将深度缓存写入(默认Zwrite on),这样下面部分的深度缓存就会更新为该物体下半边的深度缓存
		//当下面的pass渲染上半边的时候因为ZTest默认使用的是LEqual,所以当这个pass检测下面被挡住物体的深度缓存的时候会发现它等于当前的深度缓存(因为是同一个物体),所以它会把下半部也输出蓝色
		//所以使用ZTest less 也可以输出正确的结果,但是这样会多此一举
		Pass
		{
			//因为这部分被墙挡住了,所以这里使用ZTest Greater,这样就能使得挡住的部分写入到颜色缓存中,从而显现出来
			ZTest Greater
			//要使得被挡住的部分呈现半透明效果
			blend srcalpha oneminussrcalpha

			tags{"queue" = "Transparent"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos:POSITION;
			};
			
			v2f vert (appdata_base v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				return fixed4(1,1,0,0.5);
			}
			ENDCG
		}
	}
}
