﻿Shader "Unlit/DrawWave"
{
	Properties
	{
		_InputTex ("Input", 2D) = "white" {}
		_PrevTex ("Prev Result", 2D) = "white" {}
		_PrevPrevTex ("Prev Prev Result", 2D) = "white" {}
		_Stride ("Stride", Float) = 0.5
		_Parameter ("Parameter", float) = 0.1
		_Attenuation ("Attenuation", float) = 0.96
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100

		ZWrite Off
		ZTest Always
		//Cull Off
		//Blend SrcAlpha OneMinusSrcAlpha

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
				float4 vertex : SV_POSITION;
			};

			sampler2D _InputTex;
			sampler2D _PrevTex;
			sampler2D _PrevPrevTex;
			float4 _PrevTex_TexelSize;

			float _Stride;
			float _Parameter;
			float _Attenuation;

			float Remap(float _value)
			{
				return (_value*2)-1;
			}

			half InvRemap(half _value)
			{
				return (_value+1)*0.5;
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 stride = float2(_Stride, _Stride) * _PrevTex_TexelSize.xy;
				half prev = Remap(tex2D(_PrevTex, i.uv).r);
				half value = 
					(prev*2 -
						Remap(tex2D(_PrevPrevTex, i.uv).r) +(
						Remap(tex2D(_PrevTex, half2(i.uv.x+stride.x,i.uv.y)).r) +
						Remap(tex2D(_PrevTex, half2(i.uv.x-stride.x,i.uv.y)).r) +
						Remap(tex2D(_PrevTex, half2(i.uv.x,i.uv.y+stride.y)).r) +
						Remap(tex2D(_PrevTex, half2(i.uv.x,i.uv.y-stride.y)).r) -
						prev*4) *
					_Parameter);

				value -= tex2D(_InputTex, i.uv).r;
				value *= _Attenuation;
				value = InvRemap(value);

				return fixed4(value,0,0,1);
			}
			ENDCG
		}
	}
}