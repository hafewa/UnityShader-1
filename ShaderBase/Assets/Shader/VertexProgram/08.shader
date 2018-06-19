Shader "Unlit/08"
{
	SubShader
	{

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				fixed4 col:COLOR;
			};

			//本shader是将模型中的顶点沿着Y轴旋转(旋转角度是每个顶点离原点的距离转换为弧度)
			v2f vert(appdata_base v)
			{
				v2f o;

				//取得顶点在乘以时间因子
				float4 pos = v.vertex * _Time.x;

				//获得顶点离中心点的长度
				float d = length(pos);

				//取得模型本身沿Y轴旋转的矩阵（以离中心点的长度为角度）
				//float4x4 m = 
				//{
					//float4(cos(d),0,sin(d),0),
					//float4(0,1,0,0),
					//float4(-sin(d),0,cos(d),0),
					//float4(0,0,0,1)
				//};



				//顺序一定是UNITY_MATIRX_MVP在前,因为顺序一定是UNITY_MATIRX_MVP已经有了投影变换,投影变换时不可逆的,所以不能使用其他的矩阵来影响(谁在前谁就会影响后面的矩阵)UNITY_MATIRX_MVP
				//m = mul(UNITY_MATRIX_MVP,m);


				//使用矩阵的优化(矩阵有16个分量要相乘,所以比较耗)(我们这里只需要计算xz分量即可)(沿Y轴旋转的矩阵乘法规则就是下面这样,所以这样单独乘起来比较节省性能)
				float new_x = cos(d)* v.vertex.x + sin(d)*v.vertex.z;
				float new_z = -sin(d)* v.vertex.x + cos(d)*v.vertex.z;

				float4 new_pos = float4(new_x,v.vertex.y,new_z,v.vertex.w);

				o.pos = mul(UNITY_MATRIX_MVP,new_pos);
				o.col = fixed4(0,1,1,1);

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
