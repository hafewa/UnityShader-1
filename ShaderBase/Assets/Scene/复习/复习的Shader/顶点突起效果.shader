Shader "复习/顶点突起效果"
{
	Properties
	{
		_R("R",Range(1,10)) = 1
		_Offset_X("Offset_X",Range(-5,5)) = 0
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

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : TEXCOORD0;
			};

			struct v2f
			{
				float4 color : TEXCOORD0;

				float4 vertex : SV_POSITION;
			};

			float4 _MainTex_ST;
			float _R;
			//这个是圆心偏移量
			float _Offset_X;
			
			v2f vert (appdata v)
			{
				v2f o;

				float4 wpos = mul(unity_ObjectToWorld,v.vertex);
			
				float2 xz = wpos.xz;

				//X方向上进行偏移
				xz = float2(xz.x - _Offset_X,xz.y);

				//计算偏移后的点到中心点(0,0)的的距离
				float d = length(xz);

				//这样做的目的是当顶点离中心越近时d越小,而最终得到的tuqi就越大(突起越高)
				float tuqi = _R - d;

				//平地（tuqi<0）
				tuqi =tuqi<0?0:tuqi;

				float4 newVertex = float4(v.vertex.x,tuqi,v.vertex.z,v.vertex.w);

				o.vertex = mul(UNITY_MATRIX_MVP,newVertex);

				//newVertex.y就是tuqi,因为突起部分的d值比较小,那_R - d就比较大,所以是白色
				o.color = fixed4(newVertex.y,newVertex.y,newVertex.y,1);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return i.color;
			}
			ENDCG
		}
	}
}
