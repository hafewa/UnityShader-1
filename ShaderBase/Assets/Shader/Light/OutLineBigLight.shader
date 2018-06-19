Shader "Unlit/OutLineBigLight"
{
	Properties
	{
		_OutLightScale("OutLightScale",range(0,1)) = 0.2
		_InLightScale("InLightScale",range(0,1)) = 0.2
		_Bright("Bright",range(1,8)) = 2
		_InAlpha("_InAlpha",range(0,1)) = 0.5
		_MainColor("MainColor",color) = (1,1,1,1)
	}
	SubShader
	{
		//renderQueue的设置必须要写在pass的前面,否则不起作用
		//但是tags的其他标签设置不需要一定写在面
		tags{"queue" = "Transparent"}

		//这个pass是来处理物体外边框发光的效果
		Pass
		{
			blend srcalpha oneminussrcalpha
			//要做外边框发光的效果这个zWrite off一定要加,因为如果不加第一个pass的像素信息就会被写入深度缓存,第二个pass后绘制这样就会被第一个pass绘制的东西挡住,从而看不到效果
			zWrite off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				float4 vertex:TEXCOORD0;
				float3 normal:TEXCOORD1;
			};

			float _OutLightScale;
			float _Bright;
			float4 _MainColor;
			
			v2f vert (appdata_base v)
			{
				//将顶点沿着法线方向拉伸,这样就会使得物体变大
				v.vertex.xyz += v.normal * _OutLightScale;
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.vertex = v.vertex;
				o.normal = v.normal;

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				//计算世界空间法向量
				float3 N = UnityObjectToWorldNormal(IN.normal);

				//计算视向量
				float3 V = normalize(WorldSpaceViewDir(IN.vertex));

				//计算视向量和法向量的点积
				float bright = saturate(dot(N,V));

				//这里正好和物体内边框发光的做法相反,外边框离中心越近则越实,越靠近边缘则越虚
				bright = pow(bright,_Bright);

				//我们只需要当物体离中心越近时越实,离中心越远时越虚,而物体颜色不变,所以只需改变Aphla的值即可,否则物体越往外越黑,不是我们想要的效果
				_MainColor.a *= bright;

				return _MainColor;
			}
			ENDCG
		}

		//这个pass用来处理内部轮廓,上面的pass虽然实现了当物体离中心越近时越实,离中心越远时越虚,但是中间的轮廓却没了,就不是外发光的效果了
		Pass
		{
			//(反转减法,blendop sub 是正向减法,正向减法是从该pass中减去已经存在于屏幕上的像素颜色)从已经存在的屏幕中的像素颜色减去该pass所产生的颜色,因为该pass所产生的颜色是纯白色,所以减去纯白色后就内部只剩一个纯黑的轮廓,我们要的就是这个轮廓
			//因为减去的是纯白色,剩下一个纯黑的轮廓后中间部分就不透明了,要想要透明效果就不能完完全全减去一个纯白色,所以该pass输出的是一个半透的纯白色,这样上一个pass减去一个半透的纯白色后还是一个半黑半透的颜色
			blendop revsub
			//上一个pass的颜色乘以one,即让上一个pass完全通过,然后是要减去一个半透的纯白色,所这里使用这个混合srcalpha即是0.5,这样(1,1,1) * 0.5即是一个半透的纯白色
			blend srcalpha one

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos:POSITION;
			};

			float _InAlpha;

			v2f vert (appdata_base v)
			{
				v2f o;
		
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				return fixed4(1,1,1,_InAlpha);
			}
			ENDCG
		}

		//然后再在下面的pass中将内边框发光加上就可以了
		//这个pass用来计算内边框发光
		Pass
		{
			//如果没有加blendop这个关键字,混合模式默认是add,即是该pass输出的颜色*srcalpha + 上一个pass(或者已经存在于屏幕中的颜色) * oneminussrcalpha
			//如果加了blendop revsub 如上面的那个pass,那么即是 上一个pass(或者已经存在于屏幕中的颜色) * oneminussrcalpha - 该pass输出的颜色*srcalpha
			//如果加了blendop sub   即是该pass输出的颜色*srcalpha - 上一个pass(或者已经存在于屏幕中的颜色) * oneminussrcalpha
			blend srcalpha oneminussrcalpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				float4 vertex:TEXCOORD0;
				float3 normal:TEXCOORD1;
			};

			float _InLightScale;

			v2f vert (appdata_base v)
			{
				v2f o;

				o.vertex = v.vertex;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.normal = v.normal;

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				//计算世界空间法向量
				float3 N = UnityObjectToWorldNormal(IN.normal);

				//计算视向量
				float3 V = normalize(WorldSpaceViewDir(IN.vertex));

				//计算视向量和发向量的点积
				float bright = 1-saturate(dot(N,V));

				//用pow函数将衰减速度提升(越往中心去亮度迅速衰减)
				bright = pow(bright,_InLightScale);

				return fixed4(1,1,1,1) * bright;
			}
			ENDCG
		}
	}
}
