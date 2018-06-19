Shader "Custom/Shader_ProjectorDepthTexture"
{
	//这个shader是用来存放投影相机所渲染的物体的的深度z,然后再将z值存在一张纹理(Rendertexture)中
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
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 z:TEXCOORD0;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);

				o.z = o.vertex.z;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//将投影物体(本例是一个Cube)的深度缓存z值存放在一张Rendertexture中
				float d = i.z;

				//EncodeFloatRGBA是UnityCg.cginc中的方法,这个方法是把一个float类型的数据转换到一个各个分量都相同的颜色值,因为i.zw.x/i.zw.y会得到一个有很多小数点的数,然后用fixed4接收的话肯定会被截取
				//用EncodeFloatRGBA就可以避免这种截取的问题,从而把一个float类型的数据比较精确的转换到fixed4的颜色值
				fixed4 col = EncodeFloatRGBA(d);

				return col;
			}
			ENDCG
		}
	}
}
