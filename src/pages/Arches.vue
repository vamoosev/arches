<script setup>
  // Import needed Vue functions
  import { computed, onMounted, reactive, watch } from "vue";
  import { RouterLink } from "vue-router"; 
  
  // Import subcomponents 
  import PartyList from "../components/PartyList.vue";
  import ArchDiagram from "../components/ArchDiagram.vue";
  
  // Define a reactive object with the current diagram inside.
  // Vue will watch this object and update the DOM when it is modified
  function createArch(name = "New Arch") {
    return {
      name,

      // List of party representations objects (party + seat counts)
      list: [],

      // Any diagram options which will be passed to the diagram generator.
      // Currently only supports a title and denseRows boolean toggle.
      options: { denseRows: false, diagramTitle: name },
    };
  }

  var status = reactive({
    arches: [createArch()],
    selectedArchIndex: 0,
  });

  const activeArch = computed(() => {
    return status.arches[status.selectedArchIndex] ?? status.arches[0];
  });
  
  // This defines a callback function to be run when the component is mounted onto the DOM
  // This function checks the window's localStorage for a saved state and loads it.
  onMounted(() => {
    
    if (localStorage.getItem("archDiagrams")) {
      console.log("load from storage");
      let storedStatus = JSON.parse(localStorage.getItem("archDiagrams"));
      status.arches = storedStatus.arches?.length ? storedStatus.arches : [createArch()];
      status.selectedArchIndex = storedStatus.selectedArchIndex ?? 0;
    } else if (localStorage.getItem("archDiagram")) {
      console.log("load from legacy storage");
      let storedStatus = JSON.parse(localStorage.getItem("archDiagram"));
      status.arches = [
        {
          name: storedStatus.options?.diagramTitle || "New Arch",
          list: storedStatus.list || [],
          options: storedStatus.options || { denseRows: false, diagramTitle: "New Arch" },
        },
      ];
      status.selectedArchIndex = 0;
    }
  });
  
  // This defines a callback function to be run whenever the passed reactive variable is
  // updated. This function watches `status` for changes and updates the localStorage model
  // with the new value
  watch(status, (newValue) => {
    console.log("update storage");
    localStorage.setItem(
      "archDiagrams",
      JSON.stringify({ arches: newValue.arches, selectedArchIndex: newValue.selectedArchIndex })
    );
  });

  function addArch() {
    status.arches.push(createArch(`New Arch ${status.arches.length + 1}`));
    status.selectedArchIndex = status.arches.length - 1;
  }

  function selectArch(event) {
    status.selectedArchIndex = parseInt(event.target.value);
  }

  function deleteArch() {
    if (status.arches.length <= 1) {
      status.arches = [createArch()];
      status.selectedArchIndex = 0;
      return;
    }

    status.arches.splice(status.selectedArchIndex, 1);

    if (status.selectedArchIndex >= status.arches.length) {
      status.selectedArchIndex = status.arches.length - 1;
    }
  }
  
// TODO: introduce further localStorage models? Perhaps a dark mode toggle.
</script>
<template>
    <div class="flex justify-between items-center flex-wrap">
      <h1 class="text-5xl font-mono font-black text-gradient text-transparent bg-clip-text m-4 mb-0 p-2 mt-3">
          Arches<br>
          <span class="text-3xl inline-block relative -top-5 font-semibold font-sans italic"><a href="https://elexn.uk/" target="_blank">elexn.uk</a></span><br>
      </h1>

      <h2 class="text-5xl font-mono font-black text-slate-700 m-4 mb-0 p-2 mt-3 underline hover:no-underline cursor-pointer">
        <RouterLink to="/westminster/">Westminster?<br>
        <span class="text-3xl inline-block relative -top-3 font-semibold font-sans italic underline hover:no-underline">Click Here!</span><br></RouterLink>
      </h2>
  
      <div class="text-gray-400 mr-4 text-right">
        Based on the
        <a
          class="text-blue-700 underline"
          target="_blank"
          href="https://parliamentdiagram.toolforge.org/parlitest.php"
          >original Wikipedia Parliament Diagram tool</a
        >
        (<a
          class="underline text-blue-700"
          target="_blank"
          href="https://github.com/slashme/parliamentdiagram"
          >Github</a
        >)
        <br />
        Source Code available on
        <a
          class="underline text-blue-700"
          target="_blank"
          href="https://github.com/elexnuk/arches"
          >Github</a
        >.
      </div>
    </div>
  
    <div class="flex flex-wrap w-full p-4 items-start">
      <div class="w-full mb-4 flex flex-wrap items-center gap-3">
        <label class="text-slate-700 font-semibold">Open arch:</label>
        <select
          class="rounded-lg bg-white shadow px-3 py-2 border border-slate-200"
          :value="status.selectedArchIndex"
          @change="selectArch"
        >
          <option v-for="(arch, index) in status.arches" :key="arch.options.diagramTitle + index" :value="index">
            {{ arch.options.diagramTitle || arch.name }}
          </option>
        </select>
        <button
          class="px-4 py-2 rounded-md bg-green-100 text-green-700 hover:bg-green-300 transition-all focus:ring-4 ring-green-700 ring-opacity-40"
          @click="addArch"
        >
          New Arch
        </button>
        <button
          class="px-4 py-2 rounded-md bg-red-100 text-red-700 hover:bg-red-300 transition-all focus:ring-4 ring-red-700 ring-opacity-40"
          @click="deleteArch"
        >
          Delete Arch
        </button>
      </div>

      <PartyList
        class="
          bg-gray-100
          rounded-2xl
          shadow-2xl
          sm:w-full
          md:w-5/12
          mr-4
          divide-y divide-gray-100
        "
        v-bind="activeArch"
      ></PartyList>
  
      <ArchDiagram
        class="sm:w-full flex-1 ml-4 md:sticky md:top-0"
        v-bind="activeArch"
      ></ArchDiagram>
    </div>
</template>

<style scoped>
  .text-gradient {
      background-image: linear-gradient(
          -90deg,
          #8DC63F,
          #E4003B,
          #FAA61A,
          #0087DC
      );
      background-size: 400% 400%;
      animation: bg-gradient 10s ease infinite;
  }
  
  @keyframes bg-gradient {
      0% {
          background-position: 0% 50%;
      }
      50% {
          background-position: 100% 50%;
      }
      100% {
          background-position: 0% 50%;
      }
  }
  
</style>