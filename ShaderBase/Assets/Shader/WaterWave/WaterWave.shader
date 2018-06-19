Shader "Unlit/WaterWave"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_A("A",range(0.025,1)) = 0.1
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

			#include "unitycg.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				float2 uv:TEXCOORD0;
			};

			sampler2D _MainTex;

			//水波纹理
			sampler2D _WaveTex;

			float _A;
			
			v2f vert (appdata_base v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.uv = v.texcoord;

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				//将在C#脚本中生成的纹理采样后取得颜色中的rg(这里经过测试rg即是波形效果),用这个rg来作为新的uv坐标来给主纹理采样就能将波形效果叠加在主纹理上
				float2 uv = tex2D(_WaveTex,IN.uv).rg;

				//因为取得的是颜色值只在(0,1)范围,而我们要使用uv偏转的话就肯定要有正负(向左向右偏转),所以把uv再转换到(-1,1)范围
				uv = uv * 2 - 1;

				//控制波的能量(偏移越大波的能量越大)
				uv*=_A;

				//在主纹理上进行偏移
				IN.uv+=uv;

				fixed4 col = tex2D(_MainTex,IN.uv);

				return col;
			}
			ENDCG
		}
	}
}
