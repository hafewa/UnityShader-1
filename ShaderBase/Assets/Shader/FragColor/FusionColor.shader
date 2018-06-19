Shader "Unlit/FusionColor"
{
	Properties
	{
		_Center("Center",range(-3.21,3.51)) = 0
		_MainColor("MainColor",Color) = (1,1,1,1)
		_TwoColor("TwoColor",Color) = (1,1,1,1)
		_R("R",range(0,0.5)) = 0.2
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
				float z:TEXCOORD0;
			};

			float _Center;
			float4 _MainColor;
			float4 _TwoColor;
			float _R;

			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.z = v.vertex.z;
				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{

				//精简版本颜色融合算法
				if(IN.z >= _Center)
				{
					//坐标点的Y到中心的距离
					float d = IN.z - _Center;

					//获得坐标点的Y到中心的距离占_R的比例
					float f = d/_R;

					//当IN.y > _Center + _R时f等于1,此时的f最终为0,颜色为纯_MainColor
					//当不是以上情况时就是在融合带的上半部分
					f = (1-saturate(f)) * 0.5;

					return lerp(_MainColor,_TwoColor,f)*2;
				}
				else
				{
					//坐标点的Y到中心的距离
					float d = _Center - IN.z;

					//获得坐标点的Y到中心的距离占_R的比例
					float f = d/_R;

					//当IN.y < _Center - _R时f等于1,此时的f最终为0,颜色为纯_TwoColor
					//当不是以上情况时就是在融合带的下半部分
					f = (1-saturate(f)) * 0.5;

					return lerp(_TwoColor,_MainColor,f)*2;
				}

				//颜色融合算法
//				if(IN.y > _Center + _R)//处于融合带的上半部之上全部为_MainColor颜色
//				{
//					return _MainColor;
//				}
//				else if(IN.y >= _Center && IN.y <= _Center + _R)//处于融合带的上半部中
//				{
//					float d = IN.y - _Center;//因为在融合带的上半部中,所以肯定为正
//
//					//d/_R的取值范围是0-1,然后我们使得当N.y越靠近中心即d/_R越小融合的越大(取反),当N.y正好在中心的时候使得_MainColor和_TwoColor各自融合一半(最终的值还要减去0.5才能融合各自一半)
//					d = (1-d/_R) - 0.5;
//
//					//d有可能为负
//					d = saturate(d);
//
//					//这个算法实际上是_MainColor*(1-d) + _TwoColor*d
//					return lerp(_MainColor,_TwoColor,d);
//				}
//				else if(IN.y < _Center - _R)//处于融合带的下半部之下全部为 _TwoColor颜色
//				{
//					return _TwoColor;
//				}
//				else if(IN.y >= _Center - _R && IN.y < _Center)//处于融合带的下半部之中
//				{
//					float d = _Center -IN.y;//肯定为正
//
//					//d/_R的取值范围是0-1,然后我们使得当N.y越靠近中心即d/_R越小融合的越大(取反),当N.y正好在中心的时候使得_MainColor和_TwoColor各自融合一半(最终的值还要减去0.5才能融合各自一半)
//					//当IN.y正好在融合带下半部边缘的时候, _Center -IN.y最大,所以这个时候应该是全为_TwoColor,所以要取反使得d最终值为0
//					d = (1-d/_R) - 0.5;
//
//					//d有可能为负
//					d = saturate(d);
//
//					//调换顺序
//					return lerp(_TwoColor,_MainColor,d);
//				}
//
//				return lerp(_TwoColor,_MainColor,0.5);

//				if(IN.y > _Center)
//					return _MainColor;
//				else
//					return _TwoColor;

//				float d = IN.y - _Center;
//
//				d = d/abs(d);
//
//				d = d/2 + 0.5;
//
//				return lerp(_MainColor,_TwoColor,d);
			}
			ENDCG
		}
	}
}
