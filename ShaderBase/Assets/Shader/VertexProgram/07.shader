// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/07"
{
	properties 
	{
		_R("R",range(0,10)) = 1

		_OX("OX",range(-5,5)) = 0
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float _R;
			float _OX;

			struct v2f
			{
				float4 pos:POSITION;
				fixed4 col:COLOR;
			};

			v2f vert(appdata_base v)
			{
				v2f o;

				float4 wpos = mul(unity_ObjectToWorld,v.vertex);

				//取得世界坐标系的分量
				float2 xy = wpos.xz;

				//圆心的偏移
				xy = float2(xy.x -_OX,xy.y);

				//取得xz分量所组成的向量的长度
				float d = length(xy);

				//取反(向量的长度越长d(突起)值越小,反之越大)
				d = _R -d;

				d = d<0?0:d;

				float4 NewPos = float4(v.vertex.x,d,v.vertex.z,v.vertex.w);

				//这样就形成了一个以xz的中心为原点,以 _R为半径的突起,并且离中心越近突起越高,离中心越远突起越低
				o.pos = mul(UNITY_MATRIX_MVP,NewPos);

				o.col = fixed4(NewPos.y,NewPos.y,NewPos.y,1);

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
