Shader "Unlit/OutLineLight"
{

	properties
	{
		_Scale("Scale",range(1,8)) = 2
	}
	SubShader
	{
		tags{"queue" = "Transparent"}

		blend srcalpha oneminussrcalpha

		//关闭深度缓存写入
		//这样新像素就不受限制的更新屏幕上该点的颜色
		//如果要开启(默认开启)当该点的深度(z值)<=深度缓存中的深度值时更新该点的颜色,反之就会被丢弃
		//深度缓存的作用主要是为了防止离摄像机远的的物体后绘制时遮挡离摄像机距离近的物体
		zwrite off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				float4 vertex:TEXCOORD0;
				float3 normal:TEXCOORD1;
			};

			float _Scale;

			v2f vert (appdata_base v)
			{
				v2f o;

				o.vertex = v.vertex;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.normal = v.normal;

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				//计算世界空间法向量
				float3 N = UnityObjectToWorldNormal(IN.normal);

				//计算视向量
				float3 V = normalize(WorldSpaceViewDir(IN.vertex));

				//计算视向量和发向量的点积
				float bright = saturate(dot(N,V));

				//因为是边缘光,所以当视向量和法向量夹角为90度时最亮,角度越小就越暗,所以要取反
				bright = 1 - bright;

				//用pow函数将衰减速度提升(越往中心去亮度迅速衰减)
				bright = pow(bright,_Scale);

				fixed4 col = fixed4(1,1,1,1) * bright;

				return col;
			}
			ENDCG
		}
	}
}
