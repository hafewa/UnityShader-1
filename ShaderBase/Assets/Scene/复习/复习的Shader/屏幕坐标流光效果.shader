Shader "复习/屏幕坐标流光效果"
{
	Properties
	{

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

			sampler2D _MainTex;
			float dis;
			float _R;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				float2 screenPos =  float2(o.vertex.x/o.vertex.w,o.vertex.y/o.vertex.w);

				//以屏幕坐标做为颜色输出,但是这个坐标是(-1，1)之间所以要转换到(0,1)区间就要这样处理
				float huidu_x = o.vertex.x/o.vertex.w/2+0.5;

				if(screenPos.x < dis && screenPos.x > dis - _R)
				{
						//Unity会把模型的mesh周围的顶点自动进行插值运算所以效果是渐变红色而不是纯红色
						o.color = float4(1,0,0,1);
				}
				else
				{
					o.color = float4(huidu_x,huidu_x,huidu_x,1);
				}
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return  i.color;
			}
			ENDCG
		}
	}
}
