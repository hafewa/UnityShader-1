Shader "Unlit/CartoonShader"
{
	Properties {
		_MainTex("_MainTex",2D) = "white" {}
		_Color("Main Color",color)=(1,1,1,1)//物体的颜色
		_Outline("Thick of Outline",range(0,0.1))=0.02//挤出描边的粗细
		_Factor("Factor",range(0,1))=0.5//挤出多远
		_ToonEffect("Toon Effect",range(0,1))=0.5//卡通化程度（二次元与三次元的交界线）
		_Steps("Steps of toon",range(0,9))=3//色阶层数
	}
	SubShader {
		pass{//处理光照前的pass渲染
		Tags{"LightMode"="Always"}

		//前面剔除,只会显示沿着法线挤压的部分
		Cull Front
		ZWrite On
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		float _Outline;
		float _Factor;
		struct v2f {
			float4 pos:SV_POSITION;
		};

		v2f vert (appdata_full v) {
			v2f o;
			float3 dir=normalize(v.vertex.xyz);
			float3 N=v.normal;
			N = normalize(N);
		
			v.vertex.xyz+=N*_Outline;
			o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
			return o;
		}
		float4 frag(v2f i):COLOR
		{
			float4 c=0;
			return c;
		}
		ENDCG
		}//end of pass
		pass{//平行光的的pass渲染
		Tags{"LightMode"="ForwardBase"}

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		#include "lighting.cginc"
		float4 _Color;
		float _Steps;
		float _ToonEffect;
		sampler2D _MainTex;
		struct v2f {
			float4 pos:SV_POSITION;
			float3 lightDir:TEXCOORD0;
			float3 viewDir:TEXCOORD1;
			float3 normal:TEXCOORD2;
			float2 uv:TEXCOORD3;
		};

		v2f vert (appdata_full v) {
			v2f o;
			o.pos=mul(UNITY_MATRIX_MVP,v.vertex);//切换到世界坐标
			o.normal=v.normal;

			o.lightDir=ObjSpaceLightDir(v.vertex);
			o.viewDir=ObjSpaceViewDir(v.vertex);
			o.uv = v.texcoord;
			return o;
		}
		float4 frag(v2f i):COLOR
		{
			float4 c=1;
			float3 N=normalize(i.normal);
			float3 viewDir=normalize(i.viewDir);
			float3 lightDir=normalize(i.lightDir);
			float diff=max(0,dot(N,i.lightDir));//求出正常的漫反射颜色
			diff=(diff+1)/2;//做亮化处理
			diff=smoothstep(0,1,diff);//使颜色平滑的在[0,1]范围之内

			//这个其实就是将漫反射的光照限定在几个范围,当达到某个范围后就固定显示一定亮度的漫反射,当超过这个范围后又会固定显示另外一种亮度的颜色,这样整个表面就形成了几种色阶,卡通效果主要来自这里
			//_Steps越大色阶的种类就越大,明暗相间的就没有那么明显,相反就越明显
			float toon=floor(diff*_Steps)/_Steps;
			diff=lerp(diff,toon,_ToonEffect);//根据外部我们可控的卡通化程度值_ToonEffect，调节卡通与现实的比重
			fixed4 col = tex2D(_MainTex,i.uv);
			c=_Color*_LightColor0*(diff)*col;//把最终颜色混合
			return c;
		}
		ENDCG
		}
	} 
}
