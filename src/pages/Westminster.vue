<script setup>
  // Import needed Vue functions
  import { computed, onMounted, reactive, watch } from "vue";
  import { RouterLink } from "vue-router"; 
  
  // Import subcomponents 
  import WmDiagram from "../components/WmDiagram.vue";
  import WmPartyList from "../components/WmPartyList.vue";

  function createDiagram(name = "New Westminster") {
    return {
      name,

      // List of party representations objects (party + seat counts)
      list: [],

      // Any diagram options which will be passed to the diagram generator.
      options: { wingrows: 0, centercols: 0, radius: 1, spacing: 0.1, cozy: true, fullwidth: false },
    };
  }
  
  // Define a reactive object with the current diagram inside.
  // Vue will watch this object and update the DOM when it is modified
  var status = reactive({
    diagrams: [createDiagram()],
    selectedDiagramIndex: 0,
  });

  const activeDiagram = computed(() => {
    return status.diagrams[status.selectedDiagramIndex] ?? status.diagrams[0];
  });
  
  // This defines a callback function to be run when the component is mounted onto the DOM
  // This function checks the window's localStorage for a saved state and loads it.
  onMounted(() => {
    
    if (localStorage.getItem("parliamentDiagrams")) {
      console.log("load from storage");
      let storedStatus = JSON.parse(localStorage.getItem("parliamentDiagrams"));
      status.diagrams = storedStatus.diagrams?.length ? storedStatus.diagrams : [createDiagram()];
      status.selectedDiagramIndex = storedStatus.selectedDiagramIndex ?? 0;
    } else if (localStorage.getItem("parliamentDiagram")) {
      console.log("load from legacy storage");
      let storedStatus = JSON.parse(localStorage.getItem("parliamentDiagram"));
      status.diagrams = [
        {
          name: "New Westminster",
          list: storedStatus.list || [],
          options: storedStatus.options || { wingrows: 0, centercols: 0, radius: 1, spacing: 0.1, cozy: true, fullwidth: false },
        },
      ];
      status.selectedDiagramIndex = 0;
    }
  });
  
  // This defines a callback function to be run whenever the passed reactive variable is
  // updated. This function watches `status` for changes and updates the localStorage model
  // with the new value
  watch(status, (newValue) => {
    console.log("update storage");
    localStorage.setItem(
      "parliamentDiagrams",
      JSON.stringify({ diagrams: newValue.diagrams, selectedDiagramIndex: newValue.selectedDiagramIndex })
    );
  });

  function addDiagram() {
    status.diagrams.push(createDiagram(`New Westminster ${status.diagrams.length + 1}`));
    status.selectedDiagramIndex = status.diagrams.length - 1;
  }

  function selectDiagram(event) {
    status.selectedDiagramIndex = parseInt(event.target.value);
  }

  function renameDiagram(event) {
    let diagram = activeDiagram.value;

    if (!diagram) {
      return;
    }

    diagram.name = event.target.value;
  }
  
// TODO: introduce further localStorage models? Perhaps a dark mode toggle.
</script>
<template>
    <div class="flex justify-between items-center flex-wrap">
        <h1 class="text-5xl font-mono font-black text-gradient text-transparent bg-clip-text m-4 mb-0 p-2 mt-3">
          Westminster<br>
          <span class="text-3xl inline-block relative -top-5 font-semibold font-sans italic"><a href="https://elexn.uk/" target="_blank">elexn.uk</a></span><br>
      </h1>

      <h2 class="text-5xl font-mono font-black text-slate-700 m-4 mb-0 p-2 mt-3 underline hover:no-underline cursor-pointer">
        <RouterLink to="/">Arch?<br>
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
        <label class="text-slate-700 font-semibold">Open diagram:</label>
        <select
          class="rounded-lg bg-white shadow px-3 py-2 border border-slate-200"
          :value="status.selectedDiagramIndex"
          @change="selectDiagram"
        >
          <option v-for="(diagram, index) in status.diagrams" :key="diagram.name + index" :value="index">
            {{ diagram.name }}
          </option>
        </select>
        <button
          class="px-4 py-2 rounded-md bg-green-100 text-green-700 hover:bg-green-300 transition-all focus:ring-4 ring-green-700 ring-opacity-40"
          @click="addDiagram"
        >
          New Diagram
        </button>
        <label class="text-slate-700 font-semibold ml-4">Name:</label>
        <input
          class="rounded-lg bg-white shadow px-3 py-2 border border-slate-200 min-w-64"
          type="text"
          :value="activeDiagram?.name || ''"
          @input="renameDiagram"
        />
      </div>

      <WmPartyList
        :list="activeDiagram.list"
        :options="activeDiagram.options"
        class="sm:w-full flex-1 mr-4 md:sticky md:top-0"
      />
  
      <WmDiagram
        class="sm:w-full flex-1 ml-4 md:sticky md:top-0"
        v-bind="activeDiagram"
      ></WmDiagram>
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