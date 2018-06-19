// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/05"
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

			v2f vert(appdata_base v)
			{
				//顶点颜色变化(当自身顶点x分量大于0时为红,否则为绿,移动立方体并不会改变这样的颜色变化)
				v2f o;
				//if(v.vertex.x > 0)
					//o.col = fixed4(1,0,0,1);
				//else
					//o.col = fixed4(0,1,0,1);

				//当顶点为立方体的面对玩家的右上顶点时为红
				//if(v.vertex.x == 0.5 && v.vertex.y == 0.5 && v.vertex.z == -0.5)
					//o.col = fixed4(1,0,0,1);
				//else
					//o.col = fixed4(0,1,0,1);

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				
				//这个是把模型自身顶点转化为世界顶点坐标,_object2world为世界矩阵
				float4 worldPos = mul(unity_ObjectToWorld,v.vertex);

				//这样当立方体移动的时候(当立方体Position.x>0.5时会变成全红,当立方体Position.x<=0.5时会变为全绿)颜色也会随着变化
				//if(worldPos.x > 0)
					//o.col = fixed4(1,0,0,1);
				//else
					//o.col = fixed4(0,1,0,1);

				//_SinTime和_CosTime是shader内置的时间变量,它们的分量为(t/8,t/4,t/2,t),t就是另一个内置变量_Time(如同C#中的Time),每个分量的取值范围都是(-1,1),所以需要/2+0.5转化到(0,1)
				if(v.vertex.x == 0.5 && v.vertex.y == 0.5 && v.vertex.z == -0.5)
					o.col = fixed4(_SinTime.w /2 + 0.5,_CosTime.w /2 + 0.5,_SinTime.y/2 + 0.5,1);
				else
					o.col = fixed4(0,0,1,1);

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
