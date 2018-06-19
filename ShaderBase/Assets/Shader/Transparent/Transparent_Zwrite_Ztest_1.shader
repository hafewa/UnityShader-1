Shader "Unlit/Transparent_Zwrite_Ztest_1"
{
	SubShader
	{
		tags{"queue" = "Transparent"}

		Pass
		{
			blend srcalpha oneminussrcalpha

			//这个是写入深度缓存,屏幕上有颜色缓存,同时也存在深度缓存,两者之间有着密切联系,如果不写默认为on
			//深度缓存是根据摄像机近远截面形成的,近截面是0,远截面是1,当有一个像素的深度缓存小于等于(Ztest 为LEqual模式,默认是这种模式,还有很多种模式),则该像素的z值就会覆盖原来该点的深度缓存(写入),同时将颜色缓存中对应该点的颜色显示出来
			//当其他物体上的对应该点的像素如果z值又小于被覆盖之后的该点的深度缓存,则它就会又一次覆盖该点的深度缓存,导致之前的物体被后来的物体挡住,引擎就是以这样的方式来实现剔除被挡住的物体的
			//当Zwrite off时就算前面的物体z值小于前面的物体,它也不会覆盖之前该点的深度缓存,所以之前的物体不会被挡住,半透明的物体应该要求后面的物体不能被挡住,所以要使用off
			//Unity目前的版本即使不加这个off,也能看到后面的物体,可能是Unity后来改了这种半透明物体的渲染方式
			Zwrite off

			//ZTest 可取值为：Greater , GEqual , Less , LEqual , Equal , NotEqual , Always , Never , Off，默认是 LEqual，ZTest Off 等同于 ZTest Always。

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
				return fixed4(1,0,0,0.5);
			}
			ENDCG
		}
	}
}
