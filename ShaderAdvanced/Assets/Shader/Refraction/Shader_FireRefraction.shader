Shader "Unlit/Shader_FireRefraction"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "queue" = "transparent"}
		LOD 100

		//抓取屏幕纹理通道
		grabpass{}

		//这个pass主要是用来扭曲火焰背后的经过热空气膨胀的墙的画面,使得墙感觉像是有通过火折射了一样
		//如果不单单加上这个pass火焰效果就会断层,因为我们的火的粒子特效实际上用的是一张张面片在跳动,而后跳动的面片所拿到的_GrabTexture并不会包含之前面片所渲染的火的效果,_GrabTexture只会包含背景墙的内容
		//所以我们这里先进行火焰的扭曲,没有火焰效果
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
				float4 proj:TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			//抓取屏幕纹理
			sampler2D _GrabTexture;

			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.proj = ComputeGrabScreenPos(o.vertex);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				//想要扭曲只要通过_MainTex中的r通道来对i.proj.y进行偏移即可,因为该火焰贴图中红色通道不会为0,且分布不均匀(深浅不均匀),适合来作为不规则的偏移量
				i.proj.y+=col.r*0.5;

				fixed4 projCol = tex2Dproj(_GrabTexture,i.proj);
	
				return projCol;
			}
			ENDCG
		}

		//这个通道仅仅是用来显示火焰的颜色
		Pass
		{
			blend srccolor one
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
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;

			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
	
				return col;
			}
			ENDCG
		}
	}
}
