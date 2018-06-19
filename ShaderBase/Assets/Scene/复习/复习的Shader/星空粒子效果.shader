Shader "复习/星空粒子效果"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SecondTex("SecondTex",2D) = "white" {}
		_A("A",Range(0,0.1)) = 0.01
		_F("F",Range(10,50)) = 10
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _SecondTex;
			float _A;
			float _F;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//第一张纹理因为是底图所以直接采样即可
				fixed4 col = tex2D(_MainTex, i.uv);
				float2 uv = i.uv;

				float Offset_uv = _A*sin(3.14*uv*_F+ _Time.y);
				uv+= Offset_uv;
				//第二张纹理采样进行正弦移动
				fixed4 col_1 = tex2D(_SecondTex,uv);
				//将第一张图和第二张图混合
				//因为第二张纹理除了蓝色通道其他的通道都为0(黑色),这样混合的结果是黑色的夜空中有很多动态粒子的效果
				col*= col_1.b;
				uv = i.uv;
				uv-=Offset_uv;
				//反向sin采样(使得粒子动态有一种旋转的效果)
				fixed4 col_2 = tex2D(_SecondTex,uv);
				//再混合一次
				col*= col_2.b;
				//提升亮度
				return col*3;
			}
			ENDCG
		}
	}
}
