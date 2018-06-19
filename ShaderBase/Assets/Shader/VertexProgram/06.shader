Shader "Unlit/06"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "unitycg.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				fixed4 col:COLOR;
			};

			float dis;

			float rt;

			v2f vert(appdata_base v) 
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				//根据透视除法(根据小孔成像原理)获得模型在投影屏幕上的坐标(此时的坐标只有xy两个分量)
				//屏幕最左边的坐标就是-1,最右边就是1
				//w是相机离投影面的距离(真实的3D物体坐标投影到屏幕上只有XY两个坐标存在了,而这两个坐标的计算正是用真实xy坐标除以w得来)
				float2 ScreenPos = float2(o.pos.x/o.pos.w,o.pos.y/o.pos.w);

				//灰度(模型屏幕坐标的x分量对应的灰度)
				fixed huidu = o.pos.x/o.pos.w/2 +0.5;

				//当屏幕坐标在最左边时为红,在最右边时为绿
				//if(ScreenPos.x <= -1)
					//o.col = fixed4(1,0,0,1);
				//else if(ScreenPos.x >= 1)
					//o.col = fixed4(0,1,0,1);
				//else
					//o.col = fixed4(huidu,huidu,huidu,1);

				//横向的流光效果
				//if(ScreenPos.x > dis && ScreenPos.x < dis + rt)
					//o.col = fixed4(1,0,0,1);
				//else
					//o.col = fixed4(huidu,huidu,huidu,1);

				//反方向(从右向左)
				if(ScreenPos.x < dis && ScreenPos.x > dis - rt)
					o.col = fixed4(1,0,0,1);
				else
					o.col = fixed4(huidu,huidu,huidu,1);
				return o;
			}

			fixed4 frag(v2f IN):COLOR
			{
				return IN.col;
			}
			ENDCG
		}
	}
}
