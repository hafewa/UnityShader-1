Shader "Test/TransparentWall"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			// make fog work
			#pragma multi_compile_fog
			
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
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}

		pass
		{
			tags{"queue" = "transparent"}

			//***********SrcAlpha就是当前pass最终输出的颜色的Alpha(如本例子下面片段函数中的0.3)******************
			//OneMinusSrcAlpha就是拿1-SrcAlpha(也就是1-0.3)
			//最终混合的颜色是当前pass输出的颜色*SrcAlpha即是(0,1,0) *0.3 + 之前该点像素的颜色*OneMinusSrcAlpha(因为本例pass中使用了ZTest Greater(本shader物体就会渲染到墙的前面而不是后面),所以之前该点像素的颜色就是墙的颜色)
			//所以最终颜色看起来不是那么绿,因为当前pass 的alpha只有0.3,而之前墙的颜色是比较灰色的,而乘以OneMinusSrcAlpha(0.7)的到的颜色还是比较深色的
			//为什么另一半没有渲染到另一个红色透明的墙的前面,是因为透明物体的渲染队列跟实体是不一样的,这种情况比较复杂(透明物体的遮挡是比较复杂的)
			blend SrcAlpha OneMinusSrcAlpha

			ZTest Greater

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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
			
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				
				fixed4 col = fixed4(0,1,0,0.3);
				return col;
			}

			ENDCG

		}
	}
}
