Shader "复习/边缘泛光效果"
{
	Properties
	{
		_MainColor ("Texture", color) = (1,1,1,1)
		_OutLineBrightScale("OutLineBrightScale",Range(1,8)) = 2
		_InLineBrightScale("InLineBrightScale",Range(0,1)) = 0.1
		_NormalStretchValue("NormalStretchValue",Range(0,1)) = 0.2
		_InAlphaValue("InAlphaValue",Range(0,1)) = 0.3
	}
	SubShader
	{
		tags{"queue" = "Transparent"}
		LOD 100

		//第一个pass处理外边框发光效果
		Pass
		{
			ZWrite Off//关闭深度缓存否则该pass所渲染的效果会呗下面的pass挡住
			blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float3 normal : TEXCOORD0;
				float4 pos : POSITION;
				float4 vertex : TEXCOORD1;
			};

			sampler2D _MainTex;
			float _OutLineBrightScale;
			fixed4 _MainColor;
			float _NormalStretchValue;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				v.vertex.xyz += v.normal * _NormalStretchValue;//将法线拉伸
				o.pos = UnityObjectToClipPos(v.vertex);
				o.vertex = v.vertex;
				o.normal = v.normal;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//计算世界坐标法线
				float3 WorldNormal = UnityObjectToWorldNormal(i.normal);
				//计算世界坐标控件的视向量（记住两个向量点积之前最好要单位化）
				float3 WorldViewDir = normalize(WorldSpaceViewDir(i.vertex));

				//计算法向量和视向量的点积
				float bright = saturate(dot(WorldNormal,WorldViewDir));
				//这种效果是当离中心越近时dot越大, pow(dot,_OutLineBrightScale)计算过后得到的finalValue也越大,反之就越小
				float finalValue = pow(bright,_OutLineBrightScale);
				_MainColor.a *= finalValue;
				return _MainColor;
			}
			ENDCG
		}

		//这个Pass主要内部轮廓,因为本shader主要是外发光效果,没有内部轮廓就谈不上外发光
		Pass
		{
			//反转减法(从上面的pass已经输出的颜色中减去该pass输出的颜色)
			blendop revsub
			//SrcAlpha 当前pass输出的是一个透明的颜色,one是让上一个pass完全通过,再结合反转减法就表示从上面的pass已经输出的颜色中减去当前pass输出的透明的颜色
			blend SrcAlpha one
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float3 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float _InAlphaValue;

			//顶点程序
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			} 

			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(1,1,1,_InAlphaValue);//输出一个纯白的半透明的颜色
			}
			ENDCG
		}

		//这个pass用来处理内部的颜色显示(因为上面的两个pass是处理外发光和内部轮廓,所以再来一个pass来处理内部颜色显示)
		Pass
		{
			blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos : POSITION;
				float3 normal:TEXCOORD1;
				float4 vertex : TEXCOORD0;
			};

			float _InLineBrightScale;

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;
				o.vertex = v.vertex;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 WorldNormal = UnityObjectToWorldNormal(i.normal);
				float3 WorldViewDir = normalize( WorldSpaceViewDir(i.vertex));

				//这里正好跟外发光的算法相反,要的效果是内边框离中心越远越亮,离中心越近越暗
				float dotValue = 1- saturate(dot(WorldNormal,WorldViewDir));

				float finalValue = pow(dotValue,_InLineBrightScale);

				return fixed4(1,1,1,1) * finalValue;
			}

			ENDCG
		}
	}
}
