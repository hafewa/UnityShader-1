Shader "Unlit/UVWave"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_F("F",range(10,50)) = 10

		_A("A",range(0,0.1)) = 0.01

		_R("R",range(0,1)) = 0
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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _F;
			float _A;
			float _R;
			
			v2f vert (appdata_base v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				//IN.uv += _Time.x;

				//sin的值域在(-1,1),IN.uv.x加上sin后偏移的话会出现超过整张图片的范围,因此前面要加个系数(在(0.01,0.1)范围)
				//IN.uv.x +=  _A *sin(IN.uv.x * 3.14 * _F + _Time.y);

				//获取圆形波纹到中心点的距离
				float dis = distance(IN.uv,float2(0.5,0.5));
				float Scale =0;

				//将波形限定在一个半径范围内,当小于这个半径范围才有波纹
				if(dis < _R)
				{
					//这里需要注意_A如果不变,那么在_R边缘会有明显的边界,使得效果不好,因为当波越远离中心的时候波的强度理论上来说是越弱的,所以_A应该随着波的远离变小
					_A *= 1- dis/_R;
					//若是_A *sin(dis * 3.14 * _F + _Time.y*10)则是周围向中心聚拢的波形
					//sin（-x）是sinx关于x轴的对称图形.所以波就从圆心向周围扩散的波形
					Scale = _A *sin(-dis * 3.14 * _F + _Time.y*10);
					IN.uv+=Scale;
				}


				Scale = saturate(Scale);
				//最终波的区域以强化颜色输出可以明显的看出波纹(因为_A取值范围比较小,所以这里*30)
				fixed4 col = tex2D(_MainTex,IN.uv); 
				return col;
			}
			ENDCG
		}
	}
}
