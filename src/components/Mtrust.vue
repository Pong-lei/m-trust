<template>
  <div id="space">
    <h1 class="logo">
      <img src="../assets/header-logo.svg" alt="" />
    </h1>
    <div id="cont" ref="cont"></div>

    <video id="video1" src="../assets/video-01.mp4" muted ref="video1"></video>

    <video id="video2" src="../assets/video-03.mp4" muted ref="video2"></video>
  </div>
</template>

<script>
import * as THREE from "three";
import Stats from "stats.js";
import dat from "dat.gui";
// import { OrbitControls } from "three/examples/jsm/controls/OrbitControls";

import vertex from "../shader/vertexParticles.glsl";
import fragment from "../shader/fargment.glsl";

import im1end from "../assets/video-01-end.jpg";
import im3first from "../assets/video-03-first.jpg";
import im3end from "../assets/video-03-end.jpg";
import im1first from "../assets/video-01-first.jpg";

import { EffectComposer } from "three/examples/jsm/postprocessing/EffectComposer.js";
import { RenderPass } from "three/examples/jsm/postprocessing/RenderPass.js";
import { UnrealBloomPass } from "three/examples/jsm/postprocessing/UnrealBloomPass.js";

import gsap from "gsap";

export default {
  name: "space",
  data() {
    return {
      //debug
      time: { value: 0 },
      stats: null,
      post: false,
      videoSrc: [],
      videoIndex: { value: 0 },

      controls: null,
      camera: null,
      renderer: null,
      scene: null,
      camera: null,
      composer: null,
      bloomPass: null,

      setting: {
        process: { value: 0 },
        distortion: { value: 0 },
        bloomThreshold: 0,
        bloomStrength: 0,
        bloomRadius: 1,
      },
      dat: null,
      material: null,
    };
  },
  mounted() {
    this.videoSrc.push(this.$refs.video1, this.$refs.video2);
    // this.Setting();

    this.Init();
    this.addPost();
    this.onWindowResize();
    this.animatVideo();
    this.Tick();
    window.addEventListener("resize", this.onWindowResize.bind(this), false);
  },
  methods: {
    animatVideo() {
      let video1 = this.videoSrc[this.videoIndex.value];
      let video2 = this.videoSrc[this.videoIndex.value + 1];

      const callback = () => {
        let video = this.videoSrc[this.videoIndex.value];
        this.material.visible = true;
        let timeLine = gsap.timeline();
        timeLine
          .to(video, {
            duration: 0.01,
            opacity: 0,
          })
          .to(this.setting.distortion, {
            duration: 2,
            value: 2,
            ease: "power2.inOut",
          })
          .to(
            this.bloomPass,
            {
              duration: 2,
              strength: 2.8,
              ease: "power2.in",
            },
            "<"
          )
          .to(this.setting.process, {
            duration: 1,
            value: (this.videoIndex.value + 1) % 2,
          })
          .to(
            this.setting.distortion,
            {
              duration: 2,
              value: 0,
              ease: "power2.inOut",
            },
            "<"
          )
          .to(
            this.bloomPass,
            {
              duration: 2,
              strength: 0,
              ease: "power2.Out",
              onComplete: () => {
                this.videoSrc[this.videoIndex.value].currenTime = 8;
                this.videoIndex.value = (this.videoIndex.value + 1) % 2;
                this.videoSrc[this.videoIndex.value].play();
                this.videoSrc[this.videoIndex.value].style.opacity = "1";
              },
            },
            "<"
          );
      };
      video1.addEventListener("ended", callback);
      video1.addEventListener("play", () => {
        this.material.visible = false;
      });
      video2.addEventListener("ended", callback);
      video2.addEventListener("play", () => {
        this.material.visible = false;
      });
      video1.play();
    },
    addPost() {
      const renderScene = new RenderPass(this.scene, this.camera);

      this.bloomPass = new UnrealBloomPass(
        new THREE.Vector2(window.innerWidth, window.innerHeight),
        1.5,
        0.4,
        0.85
      );
      this.bloomPass.threshold = this.setting.bloomThreshold;
      // 1.16
      this.bloomPass.strength = this.setting.bloomStrength;
      //1
      this.bloomPass.radius = this.setting.bloomRadius;

      this.composer = new EffectComposer(this.renderer);
      this.composer.addPass(renderScene);
      this.composer.addPass(this.bloomPass);

      // this.dat.add(this.setting, "bloomStrength", 0, 5, 0.01);
      // this.dat.add(this.setting, "bloomRadius", 0.0, 1.0, 0.01);
      // this.dat.add(this.setting, "bloomThreshold", 0.0, 1.0, 0.01);

      this.post = true;
    },
    Setting() {
      this.dat = new dat.GUI();
      this.dat
        .add(this.setting.distortion, "value", 0, 3, 0.01)
        .name("distortion");
    },
    onWindowResize() {
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix();
      this.material.needsUpdate = true;
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      this.composer.setSize(window.innerWidth, window.innerHeight);
    },
    Init() {
      let cont = this.$refs.cont;

      //FPS checker
      // this.stats = new Stats();
      // document.body.appendChild(this.stats.dom);
      // scene
      this.scene = new THREE.Scene();

      //init group

      // camera
      this.camera = new THREE.PerspectiveCamera(
        70,
        window.clientWith / window.clientHight,
        0.001,
        5000
      );

      this.camera.position.set(0, 0, 1500);

      // geometry
      const geometry = new THREE.PlaneBufferGeometry(
        480 * 1.69,
        820 * 1.71,
        480,
        820
      );
      const material = new THREE.ShaderMaterial({
        side: THREE.DoubleSide,
        uniforms: {
          progress: this.setting.process,
          time: this.time,
          videoIndex: this.videoIndex,
          texture1f: { value: new THREE.TextureLoader().load(im1first) },
          texture1e: { value: new THREE.TextureLoader().load(im1end) },
          texture3f: { value: new THREE.TextureLoader().load(im3first) },
          texture3e: { value: new THREE.TextureLoader().load(im3end) },
          distortion: this.setting.distortion,
          pixelRatio: { value: Math.min(window.devicePixelRatio, 2) },
        },

        vertexShader: vertex,
        fragmentShader: fragment,
      });
      this.material = material;
      // this.material.visible = false;
      const plane = new THREE.Points(geometry, material);
      // plane.position.set(0, 0, 0);
      this.scene.add(plane);

      // const light = new THREE.AmbientLight(0x404040); // soft white light
      // // this.scene.add(light);

      // renderer
      this.renderer = new THREE.WebGLRenderer({ antialias: true });
      this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
      this.renderer.setClearColor(0x000000, 1);
      this.renderer.physicallyCorrectLights = true;
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      // this.renderer.physicallyCorrectLights = true
      // this.renderer.outputEncoding = THREE.sRGBEncoding;
      cont.appendChild(this.renderer.domElement);

      // control
      // this.controls = new OrbitControls(this.camera, this.renderer.domElement);
      // this.controls.update();

      // this.scene.add(new THREE.AxesHelper(5));
      // tick
    },

    Tick() {
      // this.stats.begin();
      this.time.value++;
      // this.setting.bloomStrength
      // this.renderer.render(this.scene, this.camera);

      // this.controls.update();
      if (this.post) {
        this.material.uniforms.videoIndex = this.videoIndex;
        this.bloomPass.threshold = this.setting.bloomThreshold;
        // this.bloomPass.strength = this.setting.bloomStrength;
        this.bloomPass.radius = this.setting.bloomRadius;
        this.composer && this.composer.render();
      }
      // this.stats.end();
      requestAnimationFrame(this.Tick.bind(this));
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
video {
  position: absolute;
  top: 50%;
  left: 50%;
  z-index: 10000;
  /* opacity: 1; */
  /* border: 1px solid red; */
  transform: translate(-50%, -49.9%);
  width: 40vh;
  height: 68.5vh;
}
#video2 {
  opacity: 0;
}
.logo {
  position: absolute;
  z-index: 200;

  left: 3.125vw;
  top: 38px;
  width: 200px;
  height: 58px;
}
</style>
